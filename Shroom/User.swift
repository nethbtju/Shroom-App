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
    var name: String?
}
