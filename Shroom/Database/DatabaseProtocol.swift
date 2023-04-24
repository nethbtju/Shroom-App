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
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem])
    func onCharacterChange(change: DatabaseChange, character: Character)
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    var currentUser: User? {get}
    var currentCharacter: Character? {get}
    var currentCharImage: UIImage? {set get}
    
    func addTask(name: String, dueDate: String, priority: Int32, repeatTask: Bool, unit: String) -> TaskItem
    func createNewStarter(charName: String, level: Int32, exp: Int32, health: Int32, player: User?)
    func createNewUser(name: String)
    
    func deleteTask(task: TaskItem)
    func getTaskByID(_ id: String) -> TaskItem?
    
    func setupTaskListener()
    func setupCharacterListener()
    
    func parseTaskSnapshot(snapshot: QuerySnapshot)
    func parseCharacterSnapshot(snapshot: QueryDocumentSnapshot)
}

