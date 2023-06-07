//
//  UnitTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 21/5/2023.
//

import UIKit

class UnitTableViewController: UITableViewController, UnitDetailsDelgate, DatabaseListener {
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        //
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    var delegate: UnitDetailsDelgate?
    
    var listenerType = ListenerType.task
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        getUnitTasks()
        tableView.reloadData()
    }
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        //
    }
    
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        //
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    
    weak var databaseController: DatabaseProtocol?
    
    func currentUnitIs(_ unit: Unit) {
        current = unit
    }
    
    var current: Unit?
    
    var unitDisplayer = BreakdownViewController()
    
    var allTasks: [TaskItem] = []
    
    var CELL_TASK = "taskCell"
    
    var unitTasks: [TaskItem] = []
    
    func getUnitTasks(){
        let unitCode = current?.unitCode
        let unitName = current?.unitName
        for task in allTasks {
            if task.unit == "\(unitCode ?? "") - \(unitName ?? "")"{
                unitTasks.append(task)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        guard let currentUnit = current else {
            return
        }
        navigationItem.title = "\(currentUnit.unitCode!) • \(currentUnit.unitName!)"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return unitTasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASK, for: indexPath) as! TaskTableViewCell
        let task = unitTasks[indexPath.row]
        taskCell.nameText.text = task.name
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        var date = inputFormatter.string(from: task.dueDate!)
        taskCell.dueDateText.text = date
        taskCell.expText.text = "\(task.expPoints ?? 0) exp"
        taskCell.descriptionText.text = task.quickDes
        taskCell.priorityText.text = taskCell.formatPriority(priority: task.priority)
        taskCell.reminderText.text = task.reminder
        
        let color = (current?.getColor(index: current?.colour))!
        let imageIcon = UIImage(systemName: "circle")?.withTintColor(color)
        taskCell.imageView?.image = imageIcon
        
        // put in the sorted Cell
        return taskCell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        unitDisplayer.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
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
