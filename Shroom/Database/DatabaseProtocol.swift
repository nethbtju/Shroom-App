//
//  DatabaseProtocol.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case player
    case character
    case task
    case unit
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem])
    func onListChange(change: DatabaseChange, unitList: [Unit])
    func onCharacterChange(change: DatabaseChange, character: Character)
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    var currentUser: FirebaseAuth.User? {get}
    var currentCharacter: Character? {get}
    var currentCharImage: UIImage? {set get}
    
    func addTask(name: String, quickDes: String, dueDate: Date, priority: Int32, repeatTask: String, reminder: String, unit: String) -> TaskItem
    func addTaskToList(task: TaskItem, user: String) -> Bool
    func addUnit(code: String?, name: String?, color: Int?) -> Unit
    func addUnitToList(unit: Unit, user: String) -> Bool
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32)
    func createNewAccount(email: String, password: String) async throws
    func logInToAccount(email: String, password: String) async throws
    func setUpUser() async throws
    
    func deleteTask(task: TaskItem)
    func removeTaskFromList(task: TaskItem, user: String)
    func getTaskByID(_ id: String) -> TaskItem?

    func setupTaskListener()
    func setupCharacterListener()
    func updateCharacterStats(char: Character, user: String)
    
    func parseTaskSnapshot(snapshot: QuerySnapshot)
    func parseCharacterSnapshot(snapshot: QuerySnapshot)
}

