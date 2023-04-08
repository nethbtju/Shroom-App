//
//  Player+CoreDataProperties.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var name: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var playingCharacter: Character?

}

extension Player : Identifiable {

}
