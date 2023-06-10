//
//  User.swift
//  Shroom
//
//  Created by Neth Botheju on 19/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    @DocumentID var id: String?
    var taskList: [TaskItem] = []
    var unitList: [Unit] = []
    var guild: [Character] = []
    var productivity: [String: Int] = [:]
}
