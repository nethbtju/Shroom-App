//
//  BreakdownViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 20/4/2023.
//

import UIKit
import Firebase

class BreakdownViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentChar: Character?
    
    var currentPlayer: User?

    @IBOutlet weak var currentCharacterImage: UIImageView!
    
    @IBOutlet weak var playerNameLabel: UILabel!
    
    @IBOutlet weak var shroomNameLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var hpLabel: UILabel!
    
    @IBOutlet weak var expLabel: UILabel!
    
    @IBOutlet weak var hpProgressBar: UIProgressView!
    
    @IBOutlet weak var expProgressBar: UIProgressView!
    
    var sections = 0
    
    let CELL_TODAY = "allTasksCell"
    let CELL_UPCOMING = "upComingCell"
    let CELL_ALL = "allTasksCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        /*
        let player = databaseController?.currentUser
        let shroom = databaseController?.currentCharacter
        let shroomImage = databaseController?.currentCharImage
        
        // Lets assume for now the user has JUST set their things up and the current character is in current Char variable
        currentCharacterImage.image = shroomImage
        shroomNameLabel.text = shroom?.charName
        levelLabel.text = "lvl \(shroom?.level ?? 1)"
        expLabel.text = "\(shroom?.exp ?? 0)/\((shroom?.level)! * 100)"
        hpLabel.text = "\(shroom?.health ?? 0)/\((shroom?.level)! * 100)"
        hpProgressBar.progress = 100
        expProgressBar.progress = 0
        playerNameLabel.text = player?.name*/
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //do nothing
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let allTasksCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ALL, for: indexPath)
        // do nothin
        return allTasksCell
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
