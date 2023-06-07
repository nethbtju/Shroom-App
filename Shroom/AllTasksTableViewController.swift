//
//  AllTasksTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/4/2023.
//

import UIKit
import SwiftUI

class AllTasksTableViewController: UITableViewController, DatabaseListener {
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        //
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        //
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    
    weak var currentTaskDelegate: CurrentTaskDelegate?
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    // TODO: Adding the sort by option to the sort button
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        tableView.reloadData()
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        //self.performSegue(withIdentifier: "addTaskSegue", sender: nil)
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    let SECTION_TASKS = 0
    
    let CELL_TASKS = "taskCell"
    
    var allTasks: [TaskItem] = []

    var listenerType = ListenerType.task
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.navigationItem.title = "All Tasks"
        
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
        let task = allTasks[indexPath.row]
        taskCell.nameText.text = task.name
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        var date = inputFormatter.string(from: task.dueDate!)
        taskCell.dueDateText.text = date
        taskCell.expText.text = "\(task.expPoints ?? 0) exp"
        taskCell.descriptionText.text = task.quickDes
        taskCell.priorityText.text = taskCell.formatPriority(priority: task.priority)
        taskCell.reminderText.text = task.reminder
        
        let imageIcon = UIImage(systemName: "circle")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
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
        let currentTask = allTasks[indexPath.row]
        
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
                let task = allTasks[indexPath.row]
                _ = databaseController?.currentUser?.uid
                databaseController?.deleteTask(task: task)
                self.databaseController?.removeTaskFromList(task: allTasks[indexPath.row], user: databaseController!.thisUser)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
