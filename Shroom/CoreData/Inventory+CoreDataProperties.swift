//
//  Inventory+CoreDataProperties.swift
//  Shroom
//
//  Created by Neth Botheju on 7/6/2023.
//
//

import Foundation
import CoreData


extension Inventory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inventory> {
        return NSFetchRequest<Inventory>(entityName: "Inventory")
    }

    @NSManaged public var userID: String?
    @NSManaged public var tasksCompleted: Int32
    @NSManaged public var badges: NSSet?

}

// MARK: Generated accessors for badges
extension Inventory {

    @objc(addBadgesObject:)
    @NSManaged public func addToBadges(_ value: Badge)

    @objc(removeBadgesObject:)
    @NSManaged public func removeFromBadges(_ value: Badge)

    @objc(addBadges:)
    @NSManaged public func addToBadges(_ values: NSSet)

    @objc(removeBadges:)
    @NSManaged public func removeFromBadges(_ values: NSSet)

}

extension Inventory : Identifiable {

}
