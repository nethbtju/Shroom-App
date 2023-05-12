//
//  AddTaskViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 12/5/2023.
//

import UIKit
import SwiftUI

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var quickDescTextField: UITextField!
   
    @IBOutlet weak var dueDateTextField: UIDatePicker!
    
    @IBOutlet weak var priorityTextField: UIButton!
    
    @IBOutlet weak var remindersList: UIButton!
    
    @IBOutlet weak var repeatList: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     When the user clicked the addTaskButton, t
     he button will check if the specific fields are empty or
     invalid before adding the task to the task list.
     If the input is invalid it will display an error message
     */
    @IBAction func AddTaskButton(_ sender: Any) {
        
        guard let taskName = taskNameTextField.text, taskName.isEmpty == false else {
            displayMessage(title: "Invalid", message: "Please enter a task name")
            return
        }
        
        // TODO: check if the user date is after the current date and if it is a valid date
        guard let datePicker = dueDateTextField?.date else {
        displayMessage(title: "Error", message: "Please enter a valid birth date")
        return
        }
        
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
