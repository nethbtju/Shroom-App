//
//  AddTaskViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 12/5/2023.
//

import UIKit
import SwiftUI

class AddTaskViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var quickDescTextField: UITextField!
   
    @IBOutlet weak var dueDateTextField: UIDatePicker!
    
    @IBOutlet weak var priorButton: UIButton!
    
    @IBOutlet weak var reminderButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var unitButton: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    
    var units: [Unit] = []
    
    var listenerType = ListenerType.unit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setUpPriorityButton()
        setUpRepeatButton()
        setUpReminderButton()
        
        dueDateLabel.layer.cornerRadius = 5
        dueDateLabel.layer.masksToBounds = true
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        //
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        //
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        //
    }
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
    }
    
    /// Detects changes to the unit list in the firebase controller and makes the appropriate changes
    ///
    /// - Parameters: change: DatabaseChange - Type of database changes
    ///               unitList: [Unit] - The unit list that was changed
    ///
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        units = unitList
        setupUnitButton()
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        //
    }

    /// When the user clicked the addTaskButton, the button will check if the specific fields are empty or
    /// invalid before adding the task to the task list. If the input is invalid it will display an error message
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
        
        guard let priority = setPriority(priority: priorButton.currentTitle), let reminder = reminderButton.currentTitle, let repeatFreq = repeatButton.currentTitle, let unit = unitButton.currentTitle else {
            return
        }
        
        guard let database = databaseController else {
            print("Could not call databaseController")
            return
        }
        let task = database.addTask(name: taskName, quickDes: quickDescTextField.text ?? "", dueDate: datePicker, priority: priority, repeatTask: repeatFreq, reminder: reminder, unit: unit)
        
        let user = database.thisUser
        let _ = databaseController?.addTaskToList(task: task, user: user)
        
        self.dismiss(animated: true, completion: nil)

    }
    
    /// Sets up the menu for the buttons that determine the priority of the task
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
    
    /// Sets up the menu for the buttons that determine the reminder that needs to be set for the task
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
    
    /// Sets up the menu for the buttons that determine the repetition of the task
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
    
    /// Sets up the menu for the buttons that determine the units that the user can pick between. This uses the unit list that
    /// was parsed during the database change to show the options from the user input
    func setupUnitButton(){
        unitButton.showsMenuAsPrimaryAction = true
        unitButton.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            if ((action.index(ofAccessibilityElement: (Any).self)) != 0){
                
            }
        }
        var childList: [UIAction] = []
        if units.isEmpty{
            let action = UIAction(title: "None", handler: optionClosure)
            childList.append(action)
        } else{
            for unit in units{
                let action = UIAction(title: "\(unit.unitCode ?? "") - \(unit.unitName ?? "")", handler: optionClosure)
                childList.append(action)
            }
        }
        
        unitButton.menu = UIMenu(children: childList)
        
        unitLabel.layer.cornerRadius = 5
        unitLabel.layer.masksToBounds = true
    }
    
    /// Utils function that changes the priority from a button string to a int that is needed to store in the firebase and used
    /// for calculation
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
    
    /// Adds the listener when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    /// Removes the listener when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
}
