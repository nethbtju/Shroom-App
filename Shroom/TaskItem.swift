//
//  Task.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit

class TaskItem: NSObject, Codable {
    var id: String?
    var name: String?
    var dueDate: String?
    var priority: Int32?
    var repeatTask: Bool?
    var unit: String?
    var user: String?
}
