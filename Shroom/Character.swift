//
//  Character.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit

class Character: NSObject, Codable {
    var id: String?
    var charName: String?
    var level: Int32?
    var exp: Int32?
    var health: Int32?
    var player: User?
}
