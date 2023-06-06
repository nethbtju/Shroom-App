//
//  Badge+CoreDataProperties.swift
//  Shroom
//
//  Created by Neth Botheju on 7/6/2023.
//
//

import Foundation
import CoreData


extension Badge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Badge> {
        return NSFetchRequest<Badge>(entityName: "Badge")
    }

    @NSManaged public var badgeID: String?
    @NSManaged public var badgePoints: Int32
    @NSManaged public var badgeType: Int32
    @NSManaged public var inventory: NSSet?

}

extension Badge : Identifiable {

}
