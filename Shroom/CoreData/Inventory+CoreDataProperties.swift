//
//  Inventory+CoreDataProperties.swift
//  Shroom
//
//  Created by Neth Botheju on 3/6/2023.
//
//

import Foundation
import CoreData


extension Inventory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inventory> {
        return NSFetchRequest<Inventory>(entityName: "Inventory")
    }

    @NSManaged public var badges: [Int]?
    @NSManaged public var items: NSObject?
    @NSManaged public var userID: String?

}

extension Inventory : Identifiable {

}
