//
//  Task.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

/// Tasks that get parsed into the firebase as codeables
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
