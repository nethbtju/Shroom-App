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
    
    @IBOutlet weak var priorButton: UIButton!
    
    @IBOutlet weak var reminderButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setUpPriorityButton()
        setUpRepeatButton()
        setUpReminderButton()
    }

    func setUpPriorityButton(){
        priorButton.showsMenuAsPrimaryAction = true
        priorButton.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            if ((action.index(ofAccessibilityElement: (Any).self)) != 0){
                
            }
        }
        priorButton.menu = UIMenu(children: [
            UIAction(title: "Low Priority", state: .on, handler: optionClosure),
            UIAction(title: "Mid Priority", handler: optionClosure),
            UIAction(title: "High Priority", handler: optionClosure),
        ])
        
        priorButton.layer.cornerRadius = 5
        priorButton.layer.masksToBounds = true
    }
    
    func setUpReminderButton(){
        reminderButton.showsMenuAsPrimaryAction = true
        reminderButton.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            if ((action.index(ofAccessibilityElement: (Any).self)) != 0){
                
            }
        }
        reminderButton.menu = UIMenu(children: [
            UIAction(title: "No Reminders", state: .on, handler: optionClosure),
            UIAction(title: "1 Hour Before", handler: optionClosure),
            UIAction(title: "1 Day Before", handler: optionClosure),
            UIAction(title: "1 Week Before", handler: optionClosure),
        ])
        
        reminderButton.layer.cornerRadius = 5
        reminderButton.layer.masksToBounds = true
    }
    
    func setUpRepeatButton(){
        repeatButton.showsMenuAsPrimaryAction = true
        repeatButton.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            if ((action.index(ofAccessibilityElement: (Any).self)) != 0){
                
            }
        }
        repeatButton.menu = UIMenu(children: [
            UIAction(title: "Never Repeat", state: .on, handler: optionClosure),
            UIAction(title: "Repeat Daily", handler: optionClosure),
            UIAction(title: "Repeat Weekly", handler: optionClosure),
            UIAction(title: "Repeat Monthly", handler: optionClosure),
            UIAction(title: "Repeat Yearly", handler: optionClosure),
        ])
        
        repeatButton.layer.cornerRadius = 5
        repeatButton.layer.masksToBounds = true
    }

    // When the user clicked the addTaskButton, the button will check if the specific fields are empty or
    // invalid before adding the task to the task list. If the input is invalid it will display an error message
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
        
        guard let priority = setPriority(priority: priorButton.currentTitle), let reminder = reminderButton.currentTitle, let repeatFreq = repeatButton.currentTitle else {
            return
        }
        
        var task = (databaseController?.addTask(name: taskName, quickDes: quickDescTextField.text ?? "", dueDate: datePicker, priority: priority, repeatTask: repeatFreq, reminder: reminder, unit: "None"))!
        var user = (databaseController?.currentUser?.uid)!
        databaseController?.addTaskToList(task: task, user: user)
        self.dismiss(animated: true, completion: nil)

    }
    
    
    func setPriority(priority: String?) -> Int32?{
        switch priority {
        case "Low Priority":
            return 1

        case "Mid Priority":
            return 2

        case "High Priority":
            return 3
            
        default:
            return 0
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
