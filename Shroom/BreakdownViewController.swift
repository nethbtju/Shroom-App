//
//  BreakdownViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 20/4/2023.
//

import UIKit
import Firebase

class BreakdownViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DatabaseListener {
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        units = unitList
    }
    
    
    var listenerType = ListenerType.task
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    
    weak var databaseController: DatabaseProtocol?
    
    var currentChar: Character?
    
    var currentPlayer: User?
    
    var units: [Unit] = []

    @IBOutlet weak var currentCharacterImage: UIImageView!
    
    @IBOutlet weak var playerNameLabel: UILabel!
    
    @IBOutlet weak var shroomNameLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var hpLabel: UILabel!
    
    @IBOutlet weak var expLabel: UILabel!
    
    @IBOutlet weak var hpProgressBar: UIProgressView!
    
    @IBOutlet weak var expProgressBar: UIProgressView!
    
    var sections = 0
    
    let CELL_LIST = "listCell"
    let CELL_TODAY = "allTasksCell"
    let CELL_UPCOMING = "upComingCell"
    let CELL_ALL = "allTasksCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let player = databaseController?.currentUser
        let shroom = databaseController?.currentCharacter
        let shroomImage = databaseController?.currentCharImage
        
        // Lets assume for now the user has JUST set their things up and the current character is in current Char variable
        //currentCharacterImage.image = shroomImage
        shroomNameLabel.text = shroom?.charName
        levelLabel.text = "lvl \(shroom?.level ?? 1)"
        expLabel.text = "\(shroom?.exp ?? 0)/\((shroom?.level)! * 100)"
        hpLabel.text = "\(shroom?.health ?? 0)/\((shroom?.level)! * 100)"
        hpProgressBar.progress = 100
        expProgressBar.progress = 0
        playerNameLabel.text = player?.displayName
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections == 0{
            let todayCell = tableView.dequeueReusableCell(withIdentifier: CELL_TODAY, for: indexPath)
            var content = todayCell.defaultContentConfiguration()
            content.text = "Today"
            let imageIcon = UIImage(systemName: "tray.fill")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
            content.image = imageIcon
            todayCell.contentConfiguration = content
            todayCell.accessoryType = .disclosureIndicator
            sections = 1
            return todayCell;
        }
        else if sections == 1{
            let upComingCell = tableView.dequeueReusableCell(withIdentifier: CELL_UPCOMING, for: indexPath)
            var content = upComingCell.defaultContentConfiguration()
            content.text = "Upcoming"
            let imageIcon = UIImage(systemName: "calendar")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
            content.image = imageIcon
            upComingCell.contentConfiguration = content
            upComingCell.accessoryType = .disclosureIndicator
            sections = 2
            return upComingCell
        }
        else{
            let allTasksCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL, for: indexPath)
            var content = allTasksCell.defaultContentConfiguration()
            content.text = "All Tasks"
            let imageIcon = UIImage(systemName: "checklist")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
            content.image = imageIcon
            allTasksCell.contentConfiguration = content
            allTasksCell.accessoryType = .disclosureIndicator
            return allTasksCell;
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = indexPath.row
        if cell == 0 {
            self.performSegue(withIdentifier: "todaySegue", sender: nil)
            }
        else if cell == 1 {
            self.performSegue(withIdentifier: "upComingSegue", sender: nil)
            }
        else{
            self.performSegue(withIdentifier: "allTaskSegue", sender: nil)
            }
    }

    @IBAction func addUnitButton(_ sender: Any) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //do nothing
        return units.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let unitCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_LIST, for: indexPath) as! UnitCollectionViewCell
        unitCell.unitCode.text = "FIT3178"
        unitCell.unitName.text = "iOS Development"
        return unitCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "unitPageSegue", sender: nil)
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
