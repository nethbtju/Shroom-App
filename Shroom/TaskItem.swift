//
//  Task.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

enum CodingKeys: String, CodingKey {
    case name
    case quickDes
    case dueDate
    case priority
    case repeatTask
    case unit
    case user
    case expPoints
}

class TaskItem: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var quickDes: String?
    var dueDate: Date?
    var priority: Int32?
    var repeatTask: String?
    var reminder: String?
    var unit: String?
    var user: String?
    var expPoints: Int32?
}
