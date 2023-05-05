//
//  TaskTableViewCell.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import QuartzCore

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var nameText: UILabel!
    
    @IBOutlet weak var dueDateText: UILabel!
    
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var expText: UILabel!
    
    @IBOutlet weak var reminderText: UILabel!
    
    @IBOutlet weak var priorityText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        expText.layer.cornerRadius = 5
        expText.layer.masksToBounds = true
        
        reminderText.layer.cornerRadius = 5
        reminderText.layer.masksToBounds = true
        
        priorityText.layer.cornerRadius = 5
        priorityText.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
