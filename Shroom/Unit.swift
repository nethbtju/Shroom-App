//
//  Unit.swift
//  Shroom
//
//  Created by Neth Botheju on 22/5/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class Unit: NSObject, Codable {
    @DocumentID var id: String?
    var unitCode: String?
    var unitName: String?
    var userid: String?
    var colour: Int?
}

extension Unit{
    func getColor(index: Int?) -> UIColor?{
        switch index {
        case 0:
            return .systemBlue
        case 1:
            return .systemTeal
        case 2:
            return .systemGreen
        case 3:
            return .systemYellow
        case 4:
            return .systemOrange
        case 5:
            return .systemPink
        case 6:
            return .systemRed
        case 7:
            return .systemPurple
        case 8:
            return .systemIndigo
        case 9:
            return .systemGray
        case 10:
            return .gray
        case 11:
            return .black
        default:
            return .systemBlue
        }
    }
}
