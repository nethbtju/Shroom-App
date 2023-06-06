//
//  BadgesViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 7/6/2023.
//

import UIKit

class BadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DatabaseListener {
    var listenerType: ListenerType
    
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
    
    func onBadgesChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        self.badges = inventory.badges
    }
    
    
    var badges: [Badge?]
    
    var CELL_BADGE = "badgeCell"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let badgeCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_BADGE, for: indexPath) as! BadgeCollectionViewCell
        let badge = badges[indexPath.row]
        badgeCell.badgeImage.image = UIImage(named: badge?.badgeID)
        badgeCell.badgeName.text = badge?.badgeID
        return badgeCell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
