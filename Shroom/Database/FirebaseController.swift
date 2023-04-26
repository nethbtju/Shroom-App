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
    
    var currentUser: User?
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentCharacter = Character()
        taskList = [TaskItem]()
        super.init()
        // For testing purposes
        Task {
            do {
                _ = try authController.signOut()
            }
            catch {
                fatalError("Firebase Sign Out Failed with Error\(String(describing: error))")
                }
        }
    }
    
    func createNewUser(name: String){
        Task {
            do {
                _ = try await authController.signInAnonymously()
                userRef = database.collection("users")
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
                }
        }
        let user = addUser(name: name)
        currentUser = user
    }
    
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32, player: User?){
        characterRef = database.collection("characters")
        let starterChar = addCharacter(charName: charName, level: level, exp: exp, health: health, player: currentUser)
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
    
    func addUser(name: String) -> User{
        let user = User()
        user.name = name
        if let usersRef = userRef?.addDocument(data: ["name" : name, "tasks": []]) {
            user.id = usersRef.documentID
        }
        return user
    }
     
    func addCharacter(charName: String, level: Int32, exp: Int32, health: Int32, player: User?) -> Character {
        let char = Character()
        char.charName = charName
        char.level = level
        char.exp = exp
        char.health = health
        char.player = player
        do {
            if let charRef = try characterRef?.addDocument(from: char) {
                char.id = charRef.documentID
            }
        } catch {
            print("Failed to serialize character")
        }
        return char
    }
    
    func addTask(name: String, dueDate: String, priority: Int32, repeatTask: Bool, unit: String) -> TaskItem {
        let task = TaskItem()
        task.name = name
        task.dueDate = dueDate
        task.priority = priority
        task.repeatTask = repeatTask
        task.unit = unit
        do {
            if let taskRef = try tasksRef?.addDocument(from: task) {
                task.id = taskRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        return task
    }
    
    func deleteTask(task: TaskItem){
        if let TaskID = task.id {
            tasksRef?.document(TaskID).delete()
        }
    }
    
    func cleanup() {
        
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
    
    /*func setupUserListener(){
        userRef = database.collection("users")
        userRef?.whereField("name", isEqualTo: currentUser.name).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first else {
                print("Error fetching teams: \(error!)")
                return
            }
            self.parseUserSnapshot(snapshot: userSnapshot)
        }
    }*/
    
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
        
    }
    
    func parseTaskSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedTask: TaskItem?
            do {
                parsedTask = try change.document.data(as: TaskItem.self)
            } catch {
                print("Unable to decode hero. Is the task malformed?")
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
    
    func parseCharacterSnapshot(snapshot: QueryDocumentSnapshot) {
        
    }
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot){
        
    }
    
}
