//
//  Character+CoreDataProperties.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var name: String?
    @NSManaged public var level: Int32
    @NSManaged public var exp: Int32
    @NSManaged public var health: Int32
    @NSManaged public var chosenPlayer: Player?

}

extension Character : Identifiable {

}
