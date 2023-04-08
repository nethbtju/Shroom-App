//
//  DatabaseProtocol.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case player
    case character
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onPlayerChange(change: DatabaseChange, player: Player)
    func onCharacterChange(change: DatabaseChange, character: [Character])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    var currentPlayer: Player? {get set}
    func addCharacter(charName: String, level: Int32, exp: Int32, health: Int32, player: Player?) -> Character
    func addPlayer(name: String) -> Player
}

