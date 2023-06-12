//
//  User.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

/// NSObject class that determines the user and all the data that goes into the User object
/// when parsed into the Firebase
class User: NSObject, Codable {
    @DocumentID var id: String?
    var taskList: [TaskItem] = []
    var unitList: [Unit] = []
    var guild: [Character] = []
    var productivity: [String: Int] = [:]
}
