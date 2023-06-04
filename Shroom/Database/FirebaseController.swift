//
//  FirebaseController.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreData

class FirebaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    /**
     Core Data
     */
    
    var allBadgesFetchedResultsController: NSFetchedResultsController<Badge>?
    
    var allInventoryFetchedResultsController: NSFetchedResultsController<Inventory>?
    
    var persistentContainer: NSPersistentContainer
    
    /// Adds an inventory to persistent core data when a new user is added to the firebase.
    ///
    /// - Parameters user: The ID of the user that the inventory is being created for. This is a primary
    /// key and is usually consistent with the same ID generated in the firebase when the user account is
    /// created
    ///
    /// - Returns inventory: An instance of the NSObject Inventory
    ///
    func addInventory(user: String) -> Inventory {
        let inventory = NSEntityDescription.insertNewObject(forEntityName:
        "Inventory", into: persistentContainer.viewContext) as! Inventory
        inventory.userID = user
        cleanup()
        return inventory
    }
    
    /// Sets up the inventory when the user opens the app. This fetches all instances of inventory from core data
    /// and gets out the one that is consistent with the ID of the user from the firebase log in
    ///
    /// - Throws: 'error' if the data could not be fetched from the persistent container
    ///
    /// - Returns: When setting up, if the user does not have an inventory in database, it will create one for them
    ///
    func setupInventory(){
        var inv = [Inventory]()
        let request: NSFetchRequest<Inventory> = Inventory.fetchRequest()
        let predicate = NSPredicate(format: "userID = %@", currentUser!.uid)
        request.predicate = predicate
        do {
            try inv = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if let inventory = inv.first {
            userInventory = inventory
            return
        }
        
        userInventory = addInventory(user: currentUser!.uid)
        return
    }
    
    /// Fetches all instances of Inventory Object from core data using the ID of the current logged in user
    ///
    /// - Throws: 'error' if the fetch request failed and the data could not be retrieved from persistent storage
    ///
    /// - Returns inventory: An instance of the NSObject Inventory
    ///
    func fetchAllInventory() -> Inventory {
        if allInventoryFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Inventory> = Inventory.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "userID", ascending: true)
            let predicate = NSPredicate(format: "userID == %@",
                                        currentUser!.uid)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            // Initialise Fetched Results Controller
            allInventoryFetchedResultsController =
            NSFetchedResultsController<Inventory>(fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allInventoryFetchedResultsController?.delegate = self
            
            do {
                try allInventoryFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var inventory = Inventory()
        if allInventoryFetchedResultsController?.fetchedObjects?.first != nil {
            inventory = (allInventoryFetchedResultsController?.fetchedObjects?.first)!
        }
        print(inventory.userID)
        return inventory
    }
    
    func addBadgeToInventory(badge: Badge, inventory: Inventory) -> Bool {
        return false
    }
    
    func controllerDidChangeContent(_ controller:
                                    NSFetchedResultsController<NSFetchRequestResult>){
        if controller == allInventoryFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .inventory
                    || listener.listenerType == .all {
                    listener.onInventoryChange(change: .update, inventory: fetchAllInventory())
                }
            }
        }
    }
    
    /**
     Firebase Storage
     */
    var listeners = MulticastDelegate<DatabaseListener>()
    
    
    var currentCharacter: Character?
    var currentCharImage: UIImage?
    
    var allTasksList: [TaskItem]
    var thisUser: User
    var allUnitList: [Unit]
    var progressList: [String : Int]
    var userInventory: Inventory?
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
        progressList = [String : Int]()
        badgeList = [Int]()
        
        persistentContainer = NSPersistentContainer(name: "Shroom-DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
        
        getLast7Days()
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
                self.setupInventory()
                
            } else {
                self.thisUser = self.createNewUser()
                self.setupCharacterListener()
                self.tasksRef = self.database.collection("tasks")
                self.setupTaskListener()
                self.setupUnitListener()
                self.setupProgress()
            }
        }
    }
    func createNewUser() -> User {
        var newUser = User()
        newUser.id = currentUser?.uid
        newUser.taskList = []
        newUser.unitList = []
        newUser.badges = []
        newUser.productivity = [:]
        for day in days {
            newUser.productivity[day] = 0
        }
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
        if listener.listenerType == .inventory || listener.listenerType == .all {
            listener.onInventoryChange(change: .update, inventory: fetchAllInventory())
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
    
    var days: [String] = []
    
    func getLast7Days(){
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        for _ in 1 ... 7 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let currentDateString: String = dateFormatter.string(from: date)
            days.append(currentDateString)
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!
        }
    }
    
    func setupProgress(){
        var progress = thisUser.productivity
        if progress.isEmpty {
            for day in days {
                progress[day] = 0
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let today: String = dateFormatter.string(from: Date())
        
        if let key = progress[today] {
            print("Has all days set")
            return
        }
        
        let cal = Calendar.current
        let newDate = cal.date(byAdding: Calendar.Component.day, value: -7, to: Date())
        let date7DaysAgo = dateFormatter.string(from: newDate!)
        removeDate(date: date7DaysAgo)
        addDate(date: today)
        updateProgress(user: currentUser!.uid)
    }
    
    func addDate(date: String) {
        thisUser.productivity[date] = 0
    }
    
    func removeDate(date: String) {
        thisUser.productivity.removeValue(forKey: date)
    }
    
    func addCompletedTaskToProgress(date: String, user: String) {
        let currentVal = thisUser.productivity[date]! + 1
        thisUser.productivity.updateValue(currentVal, forKey: date)
        updateProgress(user: user)
    }
    
    func updateProgress(user: String){
        userRef?.document(user).updateData([
            "productivity": thisUser.productivity
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }    }
    
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
       /*userRef = database.collection("users")
       userRef?.whereField("id", isEqualTo: currentUser?.uid).addSnapshotListener {
           (querySnapshot, error) in
           guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first else {
               print("Error fetching teams: \(error!)")
               return
           }
           self.parseUserSnapshot(snapshot: userSnapshot)
        }*/
       currentUser = authController.currentUser
           userRef = database.collection("users")
           
           guard let userID = currentUser?.uid else {
               return
           }
           
           let userDocument = userRef!.document(userID)
           
       userDocument.addSnapshotListener { documentSnapshot, error in
           guard let document = documentSnapshot else {
               print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
               return
           }
           self.parseUserSnapshot(snapshot: document)
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
    
    func parseUserSnapshot(snapshot: DocumentSnapshot){
        
        guard let snapshotData = snapshot.data() else {
            print("User document is empty.")
            return
        }
        
        if let taskReferences = snapshotData["taskList"] as? [DocumentReference] {
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
        
        if let unitReference = snapshotData["unitList"] as? [DocumentReference]{
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
        
        if let progressReference = snapshotData["productivity"] {
            thisUser.productivity = progressReference as! [String : Int]
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.progress || listener.listenerType == ListenerType.all {
                    listener.onProgressChange(change: .update, progress: progressList)
                }
            }
        }
        self.setupProgress()
    }
}
