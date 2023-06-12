//
//  UnitTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 21/5/2023.
//

import UIKit

class UnitTableViewController: UITableViewController, UnitDetailsDelgate, DatabaseListener {
    
    var delegate: UnitDetailsDelgate?
    
    var listenerType = ListenerType.task
    
    weak var databaseController: DatabaseProtocol?
    
    /// Delegate function that parses the current unit selected to the segue page
    func currentUnitIs(_ unit: Unit) {
        current = unit
    }
    
    var current: Unit?
    
    var unitDisplayer = BreakdownViewController()
    
    var allTasks: [TaskItem] = []
    
    var CELL_TASK = "taskCell"
    
    var unitTasks: [TaskItem] = []
    
    /// Gets all the tasks that have that unit listed
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
    }

    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        getUnitTasks()
        tableView.reloadData()
    }
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        //
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        //
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
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
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
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
        let date = inputFormatter.string(from: task.dueDate!)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        unitDisplayer.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
}
