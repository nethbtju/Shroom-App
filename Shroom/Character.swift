//
//  Character.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Character: NSObject, Codable {
    @DocumentID var id: String?
    var charName: String?
    var level: Int32?
    var exp: Int32?
    var health: Int32?
    var player: String?
    var charImage: String?
}
