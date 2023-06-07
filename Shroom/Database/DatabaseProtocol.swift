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

/// Types of changes that can be made to the database
enum DatabaseChange {
    case add
    case remove
    case update
}

/// Types of listeners
enum ListenerType {
    case player
    case character
    case task
    case unit
    case progress
    case badges
    case inventory
    case inventoryBadges
    case all
}

/// Listeners that wait for changes made to the database before parsing to other controllers
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem])
    func onListChange(change: DatabaseChange, unitList: [Unit])
    func onCharacterChange(change: DatabaseChange, character: Character)
    func onProgressChange(change: DatabaseChange, progress: [String : Int])
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge])
    func onInventoryChange(change: DatabaseChange, inventory: Inventory)
    func onBadgeChange(change: DatabaseChange, badges: [Badge])
}

/// Database protocols than is implemented in the Database Controller and accessible by other controllers
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    var currentUser: FirebaseAuth.User? {get}
    var thisUser: User {get}
    var currentCharacter: Character? {get}
    var currentCharImage: UIImage? {set get}
    
    func addTask(name: String, quickDes: String, dueDate: Date, priority: Int32, repeatTask: String, reminder: String, unit: String) -> TaskItem
    func addTaskToList(task: TaskItem, user: User) -> Bool
    func addUnit(code: String?, name: String?, color: Int?) -> Unit
    func addUnitToList(unit: Unit, user: String) -> Bool
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32)
    func createNewAccount(email: String, password: String) async throws
    func logInToAccount(email: String, password: String) async throws
    func setUpUser() async throws
    
    func deleteTask(task: TaskItem)
    func removeTaskFromList(task: TaskItem, user: User)
    
    func addCompletedTaskToProgress(date: String, user: String)
    func updateInventoryTasks() -> Inventory

    func updateCharacterStats(char: Character, user: String)
    
    func addBadgeToInventory(badge: Badge, inventory: Inventory) -> Bool
    
}

