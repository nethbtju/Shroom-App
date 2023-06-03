//
//  FirebaseController.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var currentCharacter: Character?
    var currentCharImage: UIImage?
    
    var allTasksList: [TaskItem]
    var thisUser: User
    var allUnitList: [Unit]
    var progressList: [Int]
    var badgeList: [Int]
    var authController: Auth
    var database: Firestore
    
    var tasksRef: CollectionReference?
    var characterRef: CollectionReference?
    var userRef: CollectionReference?
    var unitRef: CollectionReference?
    
    var currentUser: FirebaseAuth.User?
    
    var DefaultTaks: String = "DefaultUser"
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentCharacter = Character()
        allTasksList = [TaskItem]()
        thisUser = User()
        allUnitList = [Unit]()
        progressList = [Int]()
        badgeList = [Int]()
        super.init()
    }
    
    func setUpUser() async throws {
        currentUser = authController.currentUser
        userRef = database.collection("users")
        let user = userRef!.document(currentUser!.uid)
        user.getDocument { (document, error) in
            if let document = document, document.exists {
                self.setupCharacterListener()
                self.tasksRef = self.database.collection("tasks")
                self.setupTaskListener()
                self.setupUnitListener()
                self.setupUserListener()
            } else {
                self.thisUser = self.createNewUser()
                self.setupCharacterListener()
                self.tasksRef = self.database.collection("tasks")
                self.setupTaskListener()
                self.setupUnitListener()
            }
        }
        
    }
    func createNewUser() -> User {
        var newUser = User()
        newUser.id = currentUser?.uid
        newUser.taskList = []
        newUser.unitList = []
        newUser.badges = []
        newUser.productivity = [0, 0, 0, 0, 0, 0, 0]
        do {
            if let userRef = try userRef?.document(currentUser!.uid).setData(from: newUser) {
                print("Sucessfull")
            }
        } catch {
            print("Failed to serialize user")
        }
        return newUser
    }
    
    func createNewAccount(email: String, password: String) async throws {
        Task{
            do {
                let authDetails = try await authController.createUser(withEmail: email, password: password)
                print("User creation successfully completed")
                currentUser = authDetails.user
                try await setUpUser()
            }
            catch {
                print("User creation failed with error \(String(describing: error))")
            }
        }
    }
    
    func logInToAccount(email: String, password: String) async throws {
        Task{
            do {
                let authDetail = try await authController.signIn(withEmail: email, password: password)
                print("User Logged in")
                currentUser = authDetail.user
                try await setUpUser()
            }
            catch {
                print("Log in failed with error \(String(describing: error))")
            }
        }
    }
    
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32){
        characterRef = database.collection("characters")
        let starterChar = addCharacter(charName: charName, level: level, exp: exp, health: health, player: currentUser?.uid)
        currentCharacter = starterChar
    }
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        if listener.listenerType == .task || listener.listenerType == .all {
            listener.onTaskChange(change: .update, tasks: thisUser.taskList)
        }
        if listener.listenerType == .unit || listener.listenerType == .all {
            listener.onListChange(change: .update, unitList: thisUser.unitList)
        }
        if listener.listenerType == .character || listener.listenerType == .all {
            listener.onCharacterChange(change: .update, character: currentCharacter!)
        }
        if listener.listenerType == .progress || listener.listenerType == .all {
            listener.onProgressChange(change: .update, progress: thisUser.productivity)
        }
        if listener.listenerType == .badges || listener.listenerType == .all {
            listener.onBadgesChange(change: .update, badges: thisUser.badges)
        }
    }
    
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
     
    func addCharacter(charName: String, level: Int32, exp: Int32, health: Int32, player: String?) -> Character {
        let char = Character()
        char.charName = charName
        char.level = level
        char.exp = exp
        char.health = health
        char.player = player
        do {
            if let charRef = try characterRef?.document(currentUser!.uid).setData(from: char) {
                char.id = currentUser?.uid
            }
        } catch {
            print("Failed to serialize character")
        }
        return char
    }
    
    func addTaskToList(task: TaskItem, user: User) -> Bool{
        guard let taskID = task.id, let userID = currentUser?.uid else{
            return false
        }
        if let newTaskRef = tasksRef?.document(taskID) {
            userRef?.document(userID).updateData(["taskList" : FieldValue.arrayUnion([newTaskRef])])
        }
        return true
    }
    
    func addUnit(code: String?, name: String?, color: Int?) -> Unit {
        let unit = Unit()
        unit.unitCode = code
        unit.unitName = name
        unit.colour = color
        unit.userid = authController.currentUser?.uid
        do {
            if let unitsRef = try unitRef?.addDocument(from: unit) {
                unit.id = unitsRef.documentID
            }
        } catch {
            print("Failed to serialize task")
        }
        return unit
    }
    func addUnitToList(unit: Unit, user: String) -> Bool {
        guard let unitID = unit.id, unitID.isEmpty == false else{
            return false
        }
        let userID = user
        if let newUnitRef = unitRef?.document(unitID) {
            userRef?.document(userID).updateData(["unitList" : FieldValue.arrayUnion([newUnitRef])])
        }
        return true
    }
    
    func addTask(name: String, quickDes: String, dueDate: Date, priority: Int32, repeatTask: String, reminder: String, unit: String) -> TaskItem {
        let task = TaskItem()
        task.name = name
        task.quickDes = quickDes
        task.dueDate = dueDate
        task.priority = priority
        task.repeatTask = repeatTask
        task.reminder = reminder
        task.unit = unit
        task.expPoints = 10 * priority
        task.user = authController.currentUser?.uid
        do {
            if let taskRef = try tasksRef?.addDocument(from: task) {
                task.id = taskRef.documentID
            }
        } catch {
            print("Failed to serialize task")
        }
        return task
    }
    
    func deleteTask(task: TaskItem){
        if let TaskID = task.id {
            tasksRef?.document(TaskID).delete()
        }
    }
    
    func getCharacterbyID(){
        // do nothing
    }
    
    func cleanup() {
        // do nothing
    }
    
    // MARK: - Firebase Controller Specific m=Methods
    func getTaskByID(_ id: String) -> TaskItem? {
        for task in allTasksList {
            if task.id == id {
                return task
            }
        }
        return nil
    }
    
    func getUnitByID(_ id: String) -> Unit? {
        for unit in allUnitList {
            if unit.id == id {
                return unit
            }
        }
        return nil
    }
    
    func removeTaskFromList(task: TaskItem, user: User) {
        if allTasksList.contains(task), let taskID = task.id , let user = currentUser?.uid {
            if let removedTaskRef = tasksRef?.document(taskID) {
            userRef?.document(user).updateData(["taskList": FieldValue.arrayRemove([removedTaskRef])])
            }
        }
    }
    
    func updateCharacterStats(char: Character, user: String){
        do {
            _ = try characterRef?.document(user).setData(from: char)
        } catch {
            print("Could not update character")
            return
        }
    }
    
    func setupUnitListener() {
        unitRef = database.collection("units")
        unitRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseUnitSnapshot(snapshot: querySnapshot)
        }
    }
    
   func setupUserListener(){
       userRef = database.collection("users")
       userRef?.whereField("id", isEqualTo: currentUser?.uid).addSnapshotListener {
           (querySnapshot, error) in
           guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first else {
               print("Error fetching teams: \(error!)")
               return
           }
           self.parseUserSnapshot(snapshot: userSnapshot)
        }
    }
    
    func setupTaskListener() {
        tasksRef = database.collection("tasks")
        tasksRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching teams: \(error!)")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupCharacterListener() {
        characterRef = database.collection("characters")
        characterRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching teams: \(error!)")
                return
            }
            self.parseCharacterSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseUnitSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedUnit: Unit?
            do {
                parsedUnit = try change.document.data(as: Unit.self)
            } catch {
                print("Unable to decode task. Is the task malformed?")
                return
            }
            guard let unit = parsedUnit else {
                print("Document doesn't exist")
                return
            }

            if change.type == .added {
                allUnitList.insert(unit, at: Int(change.newIndex))
            } else if change.type == .modified {
                allUnitList[Int(change.oldIndex)] = unit
            } else if change.type == .removed {
                allUnitList.remove(at: Int(change.oldIndex))
            }
        }
    }
    
    func parseTaskSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedTask: TaskItem?
            do {
                parsedTask = try change.document.data(as: TaskItem.self)
            } catch {
                print("Unable to decode task. Is the task malformed?")
                return
            }
            guard let task = parsedTask else {
                print("Document doesn't exist")
                return;
            }
            
            if change.type == .added {
                allTasksList.insert(task, at: Int(change.newIndex))
            } else if change.type == .modified {
                allTasksList[Int(change.oldIndex)] = task
            } else if change.type == .removed {
                allTasksList.remove(at: Int(change.oldIndex))
            }
        }
    }
    
    func parseCharacterSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedCharacter: Character?
            do {
                parsedCharacter = try change.document.data(as: Character.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            guard let char = parsedCharacter else {
                print("Document doesn't exist")
                return;
            }
            if parsedCharacter?.player == authController.currentUser?.uid{
                currentCharacter = char
            }
        }
        listeners.invoke { (listener) in
            if listener.listenerType == .character || listener.listenerType == .all {
                listener.onCharacterChange(change: .update, character: currentCharacter!)
            }
        }
    }
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot){
        if let taskReferences = snapshot.data()["taskList"] as? [DocumentReference] {
            thisUser.taskList = []
            for reference in taskReferences {
                if let task = getTaskByID(reference.documentID) {
                        thisUser.taskList.append(task)
                }
            }
                listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.task || listener.listenerType == ListenerType.all {
                        listener.onTaskChange(change: .update, tasks: thisUser.taskList)
                    }
                }
            }
        if let unitReference = snapshot.data()["unitList"] as? [DocumentReference]{
            thisUser.unitList = []
            for reference in unitReference {
                if let unit = getUnitByID(reference.documentID){
                    thisUser.unitList.append(unit)
                }
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.unit || listener.listenerType == ListenerType.all {
                    listener.onListChange(change: .update, unitList: thisUser.unitList)
                }
            }
        }
        
        if let progressReference = snapshot.data()["productivity"] {
            thisUser.productivity = progressReference as! [Int]
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.progress || listener.listenerType == ListenerType.all {
                    listener.onProgressChange(change: .update, progress: progressList)
                }
            }
        }

        }
    
}
