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

    @NSManaged public var userID: String?
    @NSManaged public var badges: [Badge]?
    @NSManaged public var items: NSObject?
    @NSManaged public var badge: Badge?

}

extension Inventory : Identifiable {

}
