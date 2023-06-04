//
//  User.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    var id: String?
    var taskList: [TaskItem] = []
    var unitList: [Unit] = []
    var badges: [Int] = []
    var productivity: [String: Int] = [:]
}
