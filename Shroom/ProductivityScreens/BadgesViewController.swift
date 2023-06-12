//
//  BadgesViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 7/6/2023.
//

import UIKit

class BadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DatabaseListener {
    
    /// Gets all the possible badges from the persistent core database
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        allBadges = badges
    }
    
    var listenerType =  ListenerType.all
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        //
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        //
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        //
    }
    
    /// Gets the badges from the core data as it updates and displays them on the collection view by reloading the view
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        self.badges = badges
        collectionView.reloadData()
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        //
    }
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
    }
    
    weak var databaseController: DatabaseProtocol?
    
    var badges: [Badge?] = []
    
    var allBadges: [Badge] = []
    
    var CELL_BADGE = "badgeCell"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allBadges.count
    }
    
    /// Confirms the collection view to the BadgeCollectionViewCell and displays them on the page
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let badgeCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_BADGE, for: indexPath) as! BadgeCollectionViewCell
        let badgeFromAll = allBadges[indexPath.row]
        guard var badgeID = badgeFromAll.badgeID, let badgeName = badgeFromAll.badgeID else {
            return badgeCell
        }
        if badges.contains(badgeFromAll) == false {
            badgeID = "Locked\(badgeID)"
        }
        
        badgeCell.badgeImage.image = UIImage(named: badgeID)
        badgeCell.badgeName.text = badgeName
        return badgeCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the delegate up for the databse from AppDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

}
