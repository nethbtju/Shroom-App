//
//  SocialViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import UIKit
import SwiftUI

class SocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listenerType = ListenerType.all
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do nothing
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        currentCharacter = character
        loadCharacter(char: currentCharacter)
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        currentGuild = guild
    }

    var currentGuild = [Character]()
    
    var currentCharacter: Character?
    
    let CELL_GUILD = "guildCell"
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var shroomNameLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var expLabel: UILabel!
    
    @IBOutlet weak var hpLabel: UILabel!
    
    @IBOutlet weak var hpProgressBar: UIProgressView!
    
    @IBOutlet weak var expProgressBar: UIProgressView!
    
    @IBOutlet weak var shroomImg: UIImageView!
    
    func loadCharacter(char: Character?){
        guard let shroom = char, let shroomName = shroom.charName, let shroomLevel = shroom.level, let shroomExp = shroom.exp, let shroomHealth = shroom.health, let image = shroom.charImage else {
            return
        }
        let shroomImage = UIImage(named: image)
        let totalExp = Float(shroomLevel) * 100.00
        let totalHealth = Float(shroomLevel) * 200.00
        
        shroomNameLabel.text = shroomName
        levelLabel.text = "lvl \(shroomLevel)"
        expLabel.text = "\(shroomExp)/\(totalExp)"
        hpLabel.text = "\(shroomHealth)/\(totalHealth)"
        shroomImg.image = shroomImage
        
        let Hprogress = Float(shroomHealth)/totalHealth
        let Eprogress = Float(shroomExp)/totalExp
        hpProgressBar.progress = Hprogress
        expProgressBar.progress = Eprogress

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentGuild.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let guildCell = tableView.dequeueReusableCell(withIdentifier: CELL_GUILD, for: indexPath) as! GuildTableViewCell
        
        let shroom = currentGuild[indexPath.row]
        
        guard let shroomName = shroom.charName, let shroomLevel = shroom.level, let shroomExp = shroom.exp, let shroomHealth = shroom.health, let player = shroom.player, let image = shroom.charImage else {
            return guildCell
        }
        
        let totalExp = Float(shroomLevel) * 100.00
        let totalHealth = Float(shroomLevel) * 200.00
        
        let Hprogress = Float(shroomHealth)/totalHealth
        let Eprogress = Float(shroomExp)/totalExp
        
        guildCell.userDisplayName.text = player
        
        guildCell.userCharName.text = shroomName
        guildCell.userCharLevel.text = "lvl \(shroomLevel)"
        guildCell.expBar.progress = Eprogress
        guildCell.healthBar.progress = Hprogress
        guildCell.charImage.image = UIImage(named: image)
        
        if indexPath.row == 1 {
            guildCell.leaderBadge.image = UIImage(named: "Place1")
        } else if indexPath.row == 2 {
            guildCell.leaderBadge.image = UIImage(named: "Place2")
        } else if indexPath.row == 3 {
            guildCell.leaderBadge.image = UIImage(named: "Place3")
        }
        
        return guildCell
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
