//
//  CoreDataController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var characterFetchedResultsController: NSFetchedResultsController<Character>?
    var playerFetchedResultsController: NSFetchedResultsController<Player>?
    var currentPlayer: Player?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "ShroomModel")
        persistentContainer.loadPersistentStores() { (description, error) in
        if let error {
            fatalError("Failed to load Core Data stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func fetchPlayerDetails() -> Player {
        if playerFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
            playerFetchedResultsController = NSFetchedResultsController<Player>(
            fetchRequest:fetchRequest, managedObjectContext:
            persistentContainer.viewContext, sectionNameKeyPath: nil,
            cacheName: nil)
            playerFetchedResultsController?.delegate = self
            do {
                try playerFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch Request failed: \(error)")
            }
        }
        if let player = playerFetchedResultsController?.fetchedObjects{
            return player.first ?? Player()
        }
        return Player()
    }
    
    func fetchCharacterDetails() -> [Character] {
        if characterFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Character> = Character.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            characterFetchedResultsController = NSFetchedResultsController<Character>(
            fetchRequest:fetchRequest, managedObjectContext:
            persistentContainer.viewContext, sectionNameKeyPath: nil,
            cacheName: nil)
            characterFetchedResultsController?.delegate = self
            do {
                try characterFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch Request failed: \(error)")
            }
        }
        if let character = characterFetchedResultsController?.fetchedObjects{
        return character
        }
        return [Character]()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data with error \(error)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke() { listener in
            listener.onPlayerChange(change: .update, player: fetchPlayerDetails())
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .player || listener.listenerType == .all {
            listener.onPlayerChange(change: .update, player: fetchPlayerDetails())
        }
        if listener.listenerType == .character || listener.listenerType == .all {
            listener.onCharacterChange(change: .update, character: fetchCharacterDetails())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addCharacter(charName: String, level: Int32, exp: Int32, health: Int32, player: Player?) -> Character {
        let char = NSEntityDescription.insertNewObject(forEntityName:
        "Character", into: persistentContainer.viewContext) as! Character
        char.name = charName
        char.level = level
        char.exp = exp
        char.health = health
        char.chosenPlayer = player
        return char
        
    }
    func addPlayer(name: String) -> Player {
        let player = NSEntityDescription.insertNewObject(forEntityName:
        "Player", into: persistentContainer.viewContext) as! Player
        player.name = name
        player.uniqueID = name + "2345"
        return player
    }

}
