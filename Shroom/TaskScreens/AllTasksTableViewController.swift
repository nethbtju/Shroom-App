//
//  AllTasksTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/4/2023.
//

import UIKit
import SwiftUI

class AllTasksTableViewController: UITableViewController, DatabaseListener {
    
    @IBOutlet var sortByLabel: UILabel!
    
    @IBOutlet var dropDownMenu: UIButton!
    
    weak var currentTaskDelegate: CurrentTaskDelegate?
    
    let SECTION_TASKS = 0
    
    let CELL_TASKS = "taskCell"
    
    var allTasks: [TaskItem] = []
    
    var sortedByTasks: [TaskItem] = []

    var listenerType = ListenerType.all
    
    weak var databaseController: DatabaseProtocol?
    
    /// When the user clicks the button is makes the new controller appear modally to let the user add new tasks
    @IBAction func addTaskButton(_ sender: Any) {
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.navigationItem.title = "All Tasks"
        
        setUpSortByButton()
        
        guard let current = dropDownMenu.currentTitle, current != "" else {
            sortByLabel.text = "Default"
            return
        }
        sortByLabel.text = current
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
    }
    
    // TODO: Adding the sort by option to the sort button
    
    /// When tasks are added to the databse the controller is updated with the new list of tasks and the table view
    /// reloads to reflect the changes
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortList(list: allTasks)
        tableView.reloadData()
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // Configure and return a task cell
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASKS, for: indexPath) as! TaskTableViewCell
        let task = sortedByTasks[indexPath.row]
        taskCell.nameText.text = task.name
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        
        let date = inputFormatter.string(from: task.dueDate!)
        
        taskCell.dueDateText.text = date
        taskCell.expText.text = "\(task.expPoints ?? 0) exp"
        taskCell.descriptionText.text = task.quickDes
        taskCell.priorityText.text = taskCell.formatPriority(priority: task.priority)
        taskCell.reminderText.text = task.reminder
        
        guard let colour = UIColor(named: "LilacColor") else {
            print("Could not retrieve Lilac Color")
            return taskCell
        }
        
        let imageIcon = UIImage(systemName: "circle")?.withTintColor(colour, renderingMode: .alwaysOriginal)
        taskCell.imageView?.image = imageIcon
        
        return taskCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
    IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "showTaskCompletion")
        self.currentTaskDelegate = vc as? any CurrentTaskDelegate
        let currentTask = sortedByTasks[indexPath.row]
        
        if let taskDelegate = currentTaskDelegate {
            if taskDelegate.currentTaskIs(currentTask) {
            tableView.deselectRow(at: indexPath, animated: true)
            showTaskCompletionScreen(controller: self, newVC: vc)
            }
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete && indexPath.section == SECTION_TASKS {
                let task = sortedByTasks[indexPath.row]
                let _  = databaseController?.removeTaskFromList(task: allTasks[indexPath.row], user: databaseController!.thisUser)
                databaseController?.deleteTask(task: task)
            }
        }
    }
    
    func setUpSortByButton(){
        dropDownMenu.showsMenuAsPrimaryAction = true
        dropDownMenu.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            if ((action.index(ofAccessibilityElement: (Any).self)) != 0){
                self.changeSortLabel()
                self.sortList(list: self.sortedByTasks)
            }
        }
        dropDownMenu.menu = UIMenu(children: [
            UIAction(title: "Default", state: .on, handler: optionClosure),
            UIAction(title: "Priority", handler: optionClosure),
            UIAction(title: "Due Date", handler: optionClosure),
            UIAction(title: "Name", handler: optionClosure),
        ])
        
    }
    
    
    func changeSortLabel(){
        sortByLabel.text = dropDownMenu.currentTitle
    }
    
    func sortList(list: [TaskItem]){
        let drop = dropDownMenu.currentTitle
        switch drop {
        case "Default":
            sortedByTasks = list
        case "Priority":
            sortedByTasks = list.sorted(by: {$1.priority! < $0.priority!})
        case "Due Date":
            sortedByTasks = list.sorted(by: {$0.dueDate! < $1.dueDate!})
        case "Name":
            sortedByTasks = list.sorted(by: {$0.name! < $1.name!})
        case .none:
            sortedByTasks = list
        case .some(_):
            sortedByTasks = list
        }
        tableView.reloadData()
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
