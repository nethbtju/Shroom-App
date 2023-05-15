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
    
    var taskList: [TaskItem]
    var authController: Auth
    var database: Firestore
    
    var tasksRef: CollectionReference?
    var characterRef: CollectionReference?
    var userRef: CollectionReference?
    
    var currentUser: FirebaseAuth.User?
    
    var DefaultTaks: String = "DefaultUser"
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentCharacter = Character()
        taskList = [TaskItem]()
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
            } else {
                self.userRef!.document(self.currentUser!.uid).setData(["taskList": []])
                self.setupCharacterListener()
                self.tasksRef = self.database.collection("tasks")
                self.setupTaskListener()
            }
        }
        
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
            listener.onTaskChange(change: .update, tasks: taskList)
        }
        if listener.listenerType == .character || listener.listenerType == .all {
            listener.onCharacterChange(change: .update, character: currentCharacter!)
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
    
    func addTaskToList(task: TaskItem, user: String) -> Bool{
        guard let taskID = task.id, taskID.isEmpty == false else{
            return false
        }
        let userID = user
        if let newTaskRef = tasksRef?.document(taskID) {
            userRef?.document(userID).updateData(["taskList" : FieldValue.arrayUnion([newTaskRef])])
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
        task.expPoints = 100 * priority
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
    
    /*func getUserByID(_ id: String) -> User? {
        userRef?.whereField("name", isEqualTo: DEFAULT_TEAM_NAME)
    }*/
    
    func getCharacterbyID(){
        // do nothing
    }
    
    func cleanup() {
        // do nothing
    }
    
    // MARK: - Firebase Controller Specific m=Methods
    func getTaskByID(_ id: String) -> TaskItem? {
        for task in taskList {
            if task.id == id {
                return task
            }
        }
        return nil
    }
    
    func removeTaskFromList(task: TaskItem, user: String) {
        if taskList.contains(task), let taskID = task.id {
            if let removedTaskRef = tasksRef?.document(taskID) {
            userRef?.document(user).updateData(["taskList": FieldValue.arrayRemove([removedTaskRef])])
            }
        }
    }
    
    
    func setupTaskListener() {
        tasksRef = database.collection("tasks")
        tasksRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupCharacterListener() {
        characterRef = database.collection("characters")
        characterRef?.whereField("player", isEqualTo: currentUser!.uid)
            .addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching teams: \(error!)")
                return
            }
            self.parseCharacterSnapshot(snapshot: querySnapshot)
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
                taskList.insert(task, at: Int(change.newIndex))
            } else if change.type == .modified {
                taskList[Int(change.oldIndex)] = task
            } else if change.type == .removed {
                taskList.remove(at: Int(change.oldIndex))
            }
        
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.task || listener.listenerType == ListenerType.all {
                listener.onTaskChange(change: .update, tasks: taskList)
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
        
    }

    
}
