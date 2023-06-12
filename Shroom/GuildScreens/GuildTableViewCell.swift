//
//  GuildTableViewCell.swift
//  Shroom
//
//  Created by Neth Botheju on 8/6/2023.
//

import UIKit

/// Customer TableViewCell for the members added to the guild 
class GuildTableViewCell: UITableViewCell {

    @IBOutlet weak var leaderBadge: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userCharName: UILabel!
    
    @IBOutlet weak var userCharLevel: UILabel!
    
    @IBOutlet weak var healthBar: UIProgressView!
    
    @IBOutlet weak var expBar: UIProgressView!
    
    @IBOutlet weak var charImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userDisplayImage.image = UIImage(named: "GuildBack")
    }

}
