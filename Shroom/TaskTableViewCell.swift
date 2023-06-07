//
//  TaskTableViewCell.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import QuartzCore

// Customer Table View Cell that allows the tasks to show up on the table views
class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var noTasks: UILabel!
    
    @IBOutlet weak var nameText: UILabel!
    
    @IBOutlet weak var dueDateText: UILabel!
    
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var expText: UILabel!
    
    @IBOutlet weak var reminderText: UILabel!
    
    @IBOutlet weak var priorityText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        guard let exp = expText, let reminder = reminderText, let priority = priorityText else {
            return
        }
        exp.layer.cornerRadius = 5
        exp.layer.masksToBounds = true
        
        reminder.layer.cornerRadius = 5
        reminder.layer.masksToBounds = true
        
        priority.layer.cornerRadius = 5
        priority.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func formatPriority(priority: Int32?) -> String? {
        switch priority {
        case 1:
            return "!"
        case 2:
           return "!!"
        case 3:
            return "!!!"
        default:
            return "None"
        }
    }

}
