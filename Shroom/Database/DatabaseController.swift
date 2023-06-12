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

class DatabaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    // MARK: - Core Data (Create, Delete, Fetch)
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var allInventoryBadgesFetchedResultsController: NSFetchedResultsController<Badge>?
    
    var allInventoryFetchedResultsController: NSFetchedResultsController<Inventory>?
    
    var allBadgesFetchedResultsController: NSFetchedResultsController<Badge>?
    
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
        inventory.tasksCompleted = 0
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
        guard let current = currentUser?.uid  else {
            return
        }
        let predicate = NSPredicate(format: "userID = %@", current)
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
        
        userInventory = addInventory(user: current)
        return
    }
    
    /// Fetches all instances of Inventory Object from core data using the ID of the current logged in user
    ///
    /// - Throws: 'error' if the fetch request failed and the data could not be retrieved from persistent storage
    ///
    /// - Returns inventory: An instance of the NSObject Inventory
    ///
    func fetchAllInventory() -> Inventory {
        guard let current = currentUser?.uid else {
            return Inventory()
        }
        if allInventoryFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Inventory> = Inventory.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "userID", ascending: true)
            let predicate = NSPredicate(format: "userID == %@",
                                        current)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            // Initialise Fetched Results Controller
            allInventoryFetchedResultsController = NSFetchedResultsController<Inventory>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allInventoryFetchedResultsController?.delegate = self
            
            do {
                try allInventoryFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var fetchedInventory = Inventory()
        guard let inv = allInventoryFetchedResultsController?.fetchedObjects?.first else {
            return fetchedInventory
        }
        fetchedInventory = inv
        
        guard let inventory = userInventory else {
            return fetchedInventory
        }
        
        userInventory = fetchedInventory
        
        return inventory
    }
    
    /// Updates the inventory every time a user completes a task
    ///
    /// - Returns inventory: An instance of the NSObject Inventory with the updated data
    ///
    func updateInventoryTasks() -> Inventory {
        guard let inventory = userInventory else {
            print("Core Data could not update the tasks count")
            return Inventory()
        }
        
        inventory.tasksCompleted += 1
        print(inventory.tasksCompleted)
        cleanup()
        return inventory

    }
    
    /// Fetches all instances of Badge Object from core data
    ///
    /// - Throws: 'error' if the fetch request failed and the data could not be retrieved from persistent storage
    ///
    /// - Returns inventory: An instance of the NSObject Badge in an array of all badges
    ///
    func fetchAllBadges() -> [Badge] {
        
        if allBadgesFetchedResultsController == nil {
            let request: NSFetchRequest<Badge> = Badge.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "badgeType", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allBadgesFetchedResultsController =
            NSFetchedResultsController<Badge>(fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allBadgesFetchedResultsController?.delegate = self
            
            do {
                try allBadgesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let badges = allBadgesFetchedResultsController?.fetchedObjects {
            
            return badges
        }
        return [Badge]()
    }
    
    /// Adds a new badge the user has earned into the inventory
    ///
    /// - Throws: 'error' if the fetch request failed and the data could not be retrieved from persistent storage
    ///
    /// - Returns inventory: An instance of the NSObject Inventory
    ///
    func addBadgeToInventory(badge: Badge, inventory: Inventory) -> Bool {
        guard let allBadges = inventory.badges, allBadges.contains(badge) == false else {
            return false
        }
        inventory.addToBadges(badge)
        return true
    }
    
    
    /// Fetches all instances of Badge Object from core data using the ID of the current logged in user
    ///
    /// - Throws: 'error' if the fetch request failed and the data could not be retrieved from persistent storage
    ///
    /// - Returns [badge]: An array instance of the NSObject badges
    ///
    func fetchInventoryBadges() -> [Badge] {
        guard let current = currentUser?.uid else {
            return [Badge]()
        }
        if allInventoryBadgesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Badge> = Badge.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "badgeID", ascending: true)
            let predicate = NSPredicate(format: "ANY inventory.userID == %@",
                                        current)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            // Initialise Fetched Results Controller
            allInventoryBadgesFetchedResultsController = NSFetchedResultsController<Badge>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allInventoryBadgesFetchedResultsController?.delegate = self
            
            do {
                try allInventoryBadgesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var fetchedBadges = [Badge]()
        guard let badges = allInventoryBadgesFetchedResultsController?.fetchedObjects else {
            return fetchedBadges
        }
        fetchedBadges = badges
        return fetchedBadges
    }
    
    /// Adds a badge to the Badge Inventory when new badges come out
    ///
    /// - Parameters badgeID: String - The name of the badge that serves as its unique ID
    ///             badgePoints: Int32 - The amount of points the badge awards to the user when earned
    ///             badgeType: Int32 - The amount of tasks that need to be completed to earn the badge
    ///
    /// - Returns badge: An instance of the badge that was added to the badge core data
    ///
    func addbadge(badgeID: String, badgePoints: Int32, badgeType: Int32) -> Badge {
        let badge = NSEntityDescription.insertNewObject(forEntityName:
                                                        "Badge", into: persistentContainer.viewContext) as! Badge
        badge.badgeID = badgeID
        badge.badgePoints = badgePoints
        badge.badgeType = badgeType
        return badge
    }
    
    /// Listens for changes in the database that requires the inventory to be fetched again
    ///
    /// - Parameters controller: NSFetchedResultsController<NSFetchRequestResult> That sees which controller
    ///     needs to be used to get the data
    ///
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
        if controller == allInventoryBadgesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .inventoryBadges
                    || listener.listenerType == .all {
                    listener.onInventoryBadgeChange(change: .update, badges: fetchInventoryBadges())
                    
                }
            }
        }
        if controller == allBadgesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .badges
                    || listener.listenerType == .all {
                    listener.onBadgeChange(change: .update, badges: fetchAllBadges())
                    
                }
            }
        }
    }
    
    
    /// Creates a set of default badges to add to database when the app first launches to the database
    func createDefaultBadges() {
        let _ = addbadge(badgeID: "TokenBadge", badgePoints: 3, badgeType: 10)
        let _ = addbadge(badgeID: "StoneBadge", badgePoints: 50, badgeType: 20)
        let _ = addbadge(badgeID: "WaterBadge", badgePoints: 100, badgeType: 50)
        let _ = addbadge(badgeID: "LeafBadge", badgePoints: 200, badgeType: 100)
        let _ = addbadge(badgeID: "FireBadge", badgePoints: 400, badgeType: 500)
        let _ = addbadge(badgeID: "SunBadge", badgePoints: 100, badgeType: 1000)
        cleanup()
    }
    
    
    /// Saves the changes to the core data after every change
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    // MARK: - Firebase (Create, Delete, Fetch)
    var currentCharacter: Character?
    var currentCharImage: UIImage?
    
    var allCharacters: [Character]
    
    var allTasksList: [TaskItem]
    var thisUser: User
    var allUnitList: [Unit]
    var userInventory: Inventory?
    var badgeList: [Badge?]
    var authController: Auth
    var database: Firestore
    
    var days: [String] = []
    
    var tasksRef: CollectionReference?
    var characterRef: CollectionReference?
    var userRef: CollectionReference?
    var unitRef: CollectionReference?
    
    var currentUser: FirebaseAuth.User?
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentCharacter = Character()
        allTasksList = [TaskItem]()
        thisUser = User()
        allUnitList = [Unit]()
        badgeList = [Badge]()
        allCharacters = [Character]()
        
        // Sets up the persistent container
        persistentContainer = NSPersistentContainer(name: "Shroom-DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
        
        getLast7Days()
        
        // MARK: For testing purposes logs out of current signed in controller
        /*do {
            try authController.signOut()
        } catch {
            print("could not sign out")
        }*/
        
        // MARK: For testing purposes wipes the core database
        /*let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Badge")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to delete data: \(error)")
        }
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save changes: \(error)")
        }*/
    }
    
    /// Sets up the user by fetching all needed documents and fields from the firebase
    ///
    /// - Throws: 'Error' - if the document could not sucessfully be fetched from the firebase
    ///
    func setUpUser() async throws {
        currentUser = authController.currentUser
        userRef = database.collection("users")
        let user = userRef!.document(currentUser!.uid)
        user.getDocument { (document, error) in
            if let document = document, document.exists == false {
                self.thisUser = self.createNewUser()
            }
            self.tasksRef = self.database.collection("tasks")
            Task{
                do {
                    self.setupCharacterListener()
                    self.setupUnitListener()
                    self.setupTaskListener()
                    self.setupUserListener()
                }
            }
            self.setupInventory()
        }
        if fetchAllBadges().count == 0 {
            createDefaultBadges()
        }
    }
    
    /// Creates a new user and adds into the firebase
    ///
    /// - Returns: An instance of a user that has been sucessfully added to the firebase
    ///
    func createNewUser() -> User {
        let newUser = User()
        newUser.id = currentUser?.uid
        newUser.taskList = []
        newUser.unitList = []
        newUser.guild = []
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
    
    /// Creates a new account for the user in the FireBase Authentication
    ///
    /// - Parameters: email - String email address the user creates
    ///               password - string password the user creates
    ///
    /// - Throws: 'Error' If the user could not be sucessfully created and added to the FireAuth
    ///
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
    
    /// Logs into the account of the user details provided given that the user already exists in the FireAuth
    ///
    /// - Parameters: email - String email address the user creates
    ///               password - string password the user creates
    ///
    /// - Throws: 'Error' If the user could not be sucessfully logged
    ///
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
    
    /// Adds listeners for the firebase when the data is updated, the corresponding controllers will also recieve this
    /// information without having to access the firebase every time
    ///
    /// - Parameters: listener: DatabaseListener - The type of listener
    ///
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
        if listener.listenerType == .inventoryBadges || listener.listenerType == .all {
            listener.onInventoryBadgeChange(change: .update, badges: fetchInventoryBadges())
        }
        if listener.listenerType == .inventory || listener.listenerType == .all {
            listener.onInventoryChange(change: .update, inventory: fetchAllInventory())
        }
        if listener.listenerType == .badges || listener.listenerType == .all {
            listener.onBadgeChange(change: .update, badges: fetchAllBadges())
        }
        if listener.listenerType == ListenerType.guild || listener.listenerType == ListenerType.all {
            listener.onGuildChange(change: .update, guild: thisUser.guild)
        }
    }
    
    /// Removes the listener
    ///
    /// - Parameters: listener: DatabaseListener - The type of listener
    ///
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    // TODO: See if you can get rid of this
    
    /// Creates a new starter character for the user when they first sign up
    ///
    /// - Parameters: charName: String - Name of the character that matches the characters
    ///               level: Int32 -The level of the character to begin with, usually this is 1
    ///               exp:  Int32 - The amount of experience points the new character added has
    ///               health: Int32 - The amount of health points the character has
    ///
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32, charImageName: String){
        characterRef = database.collection("characters")
        let starterChar = addCharacter(charName: charName, level: level, exp: exp, health: health, player: currentUser?.displayName, charImage: charImageName)
        currentCharacter = starterChar
        setupCharacterListener()
    }
    
    /// Adds the character that is created to the firebase
    ///
    /// - Parameters: charName: String - Name of the character that matches the characters
    ///               level: Int32 -The level of the character to begin with, usually this is 1
    ///               exp:  Int32 - The amount of experience points the new character added has
    ///               health: Int32 - The amount of health points the character has
    /// - Returns Character - An instance of the character that was created
    ///
    func addCharacter(charName: String, level: Int32, exp: Int32, health: Int32, player: String?, charImage: String) -> Character {
        
        let char = Character()
        char.charName = charName
        char.level = level
        char.exp = exp
        char.health = health
        char.player = player
        char.charImage = charImage
        do {
            if let charRef = try characterRef?.document(currentUser!.uid).setData(from: char) {
                print("Sucessfully created Character")
                char.id = currentUser?.uid
            }
        } catch {
            print("Failed to serialize character")
        }
        return char
    }
    
    /// Adds the character to the user's guild
    ///
    /// - Parameters: uniqueID: String - The uniqueID of the user to add the character to their guild and vice versa
    ///
    /// - Returns: Bool: whether the user ID was valid to add the player
    ///
    func addCharacterToGuild(uniqueID: String) -> Bool {
        guard let userID = currentUser?.uid else{
            return false
        }
        
        if let newCharRef = characterRef?.document(uniqueID) {
            userRef?.document(userID).updateData(["guild" : FieldValue.arrayUnion([newCharRef])])
        } else {
            print("Could not add character to guild")
        }
        
        if let otherPlayerCharRef = characterRef?.document(userID) {
            userRef?.document(uniqueID).updateData(["guild" : FieldValue.arrayUnion([otherPlayerCharRef])])
            print("Could not add character to other players guild")
        }
        
        return true
    }
    
    /// Update the characters statistics in the firebase
    ///
    /// - Parameters: char: Character - The character that needs to be updated
    ///               user: String - The userID of the user that character needs to be updated for
    ///
    /// - Throws: 'Error' - If the character could not be updated
    ///
    func updateCharacterStats(char: Character, user: String) {
        do {
            try characterRef?.document(user).setData(from: char)
        } catch {
            print("Could not update character")
            return 
        }
    }
    
    /// Adds new task to the firebase
    ///
    /// - Parameters: name: String - Name of the task being added
    ///               quickDes: String - A quick description of the task
    ///               dueDate: Date - Date the task is due
    ///               priority: Int32 - How important the task is
    ///               repeatTask: String - Is it a repeating and how often to repeat?
    ///               reminder: String - a reminder when the task is due
    ///               unit: String - unit the task belongs to
    ///
    /// - Throws: 'Error' - If the task could not be added
    ///
    /// - Returns: An instance of the task that was added to the firebase
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
    
    /// Deletes task from firebase
    ///
    /// - Parameters: task: TaskItem - The task to be deleted
    ///
    func deleteTask(task: TaskItem){
        if let TaskID = task.id {
            tasksRef?.document(TaskID).delete()
        }
    }
    
    /// Adds new task to the the list of tasks the user has
    ///
    /// - Parameters: task: TaskItem - the task that is being added to the user's list
    ///               user: User - The user the task is being added to
    ///
    /// - Returns: Bool to if the task was added sucessfully or not
    ///
    func addTaskToList(task: TaskItem, user: User) -> Bool{
        guard let taskID = task.id, let userID = currentUser?.uid else{
            return false
        }
        if let newTaskRef = tasksRef?.document(taskID) {
            userRef?.document(userID).updateData(["taskList" : FieldValue.arrayUnion([newTaskRef])])
        }
        return true
    }
    
    /// Deletes the task from the list
    ///
    /// - Parameters: task: TaskItem - the task that is being added to the user's list
    ///               user: User - The user the task is being added to
    ///
    func removeTaskFromList(task: TaskItem, user: User) {
        if allTasksList.contains(task), let taskID = task.id , let user = currentUser?.uid {
            if let removedTaskRef = tasksRef?.document(taskID) {
            userRef?.document(user).updateData(["taskList": FieldValue.arrayRemove([removedTaskRef])])
            }
        }
    }
    
    /// Gets the task from the user's task list
    ///
    /// - Parameters: id: String - ID of the task
    ///
    /// - Returns: task: TaskItem the task that was fetched from the list, else returns nil
    ///
    func getTaskByID(_ id: String) -> TaskItem? {
        for task in allTasksList {
            if task.id == id {
                return task
            }
        }
        return nil
    }
    
    /// Gets the character  from the all characters to exist
    ///
    /// - Parameters: id: String - ID of the character
    ///
    /// - Returns: task: Character - the character that was fetched from the list, else returns nil
    ///
    func getCharacterByID(_ id: String) -> Character? {
        for char in allCharacters {
            if char.id == id {
                return char
            }
        }
        return nil
    }
    
    /// Adds the unit to the firebase
    ///
    /// - Parameters: code: String - The code of the unit
    ///               name: String - Name of the unit
    ///               color: Int - colour of the unit
    ///
    ///- Throws: 'Error' if the unit could not be added to the firebase
    ///
    ///- Returns: unit: Unit - new unit that was added to the firebase
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
    
    /// Adds the unit to the user's list
    ///
    /// - Parameters: unit: Unit - the unit that is being added to the user's list
    ///               user: User - The user the task is being added to
    ///
    ///- Returns: Bool whether the unit was added to the list or not
    ///
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
    
    /// Gets the unit from the user's unit list
    ///
    /// - Parameters: id: String - ID of the unit
    ///
    /// - Returns: unit: Unit the unit that was fetched from the list, else returns nil
    ///
    func getUnitByID(_ id: String) -> Unit? {
        for unit in allUnitList {
            if unit.id == id {
                return unit
            }
        }
        return nil
    }
    
    /// Sets up the progress of the user depending on the date it is today and the last 7 days of progress the user
    /// has stored in the firebase
    func setupProgress(){
        var progress = thisUser.productivity
        
        if progress.isEmpty {
            for day in days {
                progress[day] = 0
            }
        } else {
            for day in days{
                if progress[day] == nil {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM"
                    guard var thisDay = dateFormatter.date(from: day) else {
                        print("Could not return date")
                        return
                    }
                    var dateComponent = DateComponents()
                    dateComponent.day = -7
                    guard let pastDate = Calendar.current.date(byAdding: dateComponent, to: thisDay) else {
                        print("Could not convert date to past date")
                        return
                    }
                    
                    dateFormatter.dateFormat = "dd/MM"
                    let pastDateString: String = dateFormatter.string(from: pastDate)
                    if (thisUser.productivity[pastDateString] != nil) {
                        thisUser.productivity.removeValue(forKey: pastDateString)
                    }
                    thisUser.productivity[day] = 0
                    updateProgress(user: currentUser!.uid)
                    
                }
            }
        }
    }
    
    /// Adds a completed task to the user's progress bars by incrementing their activity on the current
    /// date by 1
    ///
    /// - Parameters: date: String - The current date in the format specified
    ///               user: String - The ID of the user
    ///
    func addCompletedTaskToProgress(date: String, user: String) {
        let currentVal = thisUser.productivity[date]! + 1
        thisUser.productivity.updateValue(currentVal, forKey: date)
        updateProgress(user: user)
    }
    
    /// Updates the user's progress in the firebase
    ///
    /// - Parameters: user: String - The ID of the user
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
    
    /// Sets up the listener that checks for any changes to the character when their stats change in the
    /// firebase and updates the snapshot as needed
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
    
    /// Parses the character snapshot and gets the instance of the character from the firebase
    ///
    /// - Parameters: snapshot: QuerySnapshot - The snapshot of the changes made to the firebase
    ///
    func parseCharacterSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedCharacter: Character?
            do {
                parsedCharacter = try change.document.data(as: Character.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed? Occuring error \(error)")
                return
            }
            guard let char = parsedCharacter else {
                print("Document doesn't exist")
                return;
            }
            if change.type == .added {
                allCharacters.insert(char, at: Int(change.newIndex))
            } else if change.type == .modified {
                allCharacters[Int(change.oldIndex)] = char
            } else if change.type == .removed {
                allCharacters.remove(at: Int(change.oldIndex))
            }
        }
        
        guard let id = currentUser?.uid else {
            return
        }
        currentCharacter = getCharacterByID(id)
        
        listeners.invoke { (listener) in
            if listener.listenerType == .character || listener.listenerType == .all {
                listener.onCharacterChange(change: .update, character: currentCharacter!)
            }
        }
    }
    
    /// Sets up the listener that checks for any changes to the unit  when the firebase change
    ///  and updates the snapshot as needed
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
    
    /// Parses the unit snapshot and gets the instance of the units from the firebase
    ///
    /// - Parameters: snapshot: QuerySnapshot - The unit snapshot for the current user
    ///
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
    
    /// Sets up the listener that checks for any changes to the tasks  when the firebase change
    ///  and updates the snapshot as needed
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
    
    /// Parses the task snapshot and gets the instance of the tasks from the firebase
    ///
    /// - Parameters: snapshot: QuerySnapshot - The task snapshot for the current user
    ///
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
    
    /// Sets up the listener that checks for any changes to the user when the firebase change
    ///  and updates the snapshot as needed
    func setupUserListener(){
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
    
    /// Parses the user snapshot from the firebase and sets up a listener for the productivity, tasks and units the specific user has
    ///
    /// - Parameters: snapshot: DocumentSnapshot - The snapshot of the current user to get their details
    ///
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
        
        if let charReference = snapshotData["guild"] as? [DocumentReference]{
            for reference in charReference {
                if let char = getCharacterByID(reference.documentID){
                    if thisUser.guild.contains(char) == false {
                        thisUser.guild.append(char)
                    }
                }
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.guild || listener.listenerType == ListenerType.all {
                    listener.onGuildChange(change: .update, guild: thisUser.guild)
                }
            }
        }
        
        if let progressReference = snapshotData["productivity"] {
            thisUser.productivity = progressReference as! [String : Int]
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.progress || listener.listenerType == ListenerType.all {
                    listener.onProgressChange(change: .update, progress: thisUser.productivity)
                }
            }
        }
        self.setupProgress()
    }
    
    // MARK: Firebase Utils
    
    /// Gets the last 7 days from the current date to shift the dates to cater the new day
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
}
