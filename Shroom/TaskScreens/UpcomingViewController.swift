//
//  UpcomingViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 16/5/2023.
//

import UIKit

class UpcomingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener{
    
    @IBOutlet weak var tableView: UITableView!
    
    var listenerType = ListenerType.task
    
    let CELL_TASKS = "taskCell"
    
    var allTasks: [TaskItem] = []
    
    var sortedByDateTasks: [TaskItem] = []
    
    var dates: [String] = []
    
    var allDates: [String: [TaskItem]] = [:]
    
    weak var databaseController: DatabaseProtocol?

    let currentDate = Date()
    
    /// When add task button is clicked the page modallu shows the half sheet page to add tasks
    @IBAction func addTaskButton(_ sender: Any) {
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    /// Splits the tasks by the date they are due into a list of lists.
    /// It only displays the next upcoming 5 days of tasks.
    func splitByDate(){
        var counter = 5
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        
        for item in sortedByDateTasks{
            guard let dueDate = item.dueDate else {
                print("Item has no due date")
                return
            }
            let date = inputFormatter.string(from: dueDate)
            
            if allDates.contains(where: {$0.key == date}){
                guard var dateList = allDates[date] else {
                    print("Cannot find date in all dates list")
                    return
                }
                dateList.append(item)
                allDates.updateValue(dateList, forKey: date)
                
            } else if counter != 0 {
                allDates[date] = [item]
                dates.append(date)
                counter -= 1
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    /// When there is a new task added to the database, it reflects the changes and calls the sort by take function
    /// to resort the tasks to add new tasks to the right date list 
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortedByDateTasks = allTasks.sorted(by: {$0.dueDate! < $1.dueDate!})
        splitByDate()
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
    }
    
    /**
     Returns 5 sections for the 5 day upcoming view it will show
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = allDates.count
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tasks_for_day = allDates[dates[section]] else {
            return 0
        }
        return tasks_for_day.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASKS, for: indexPath) as! TaskTableViewCell
        let date = dates[indexPath.section]
        let alltask = allDates[date]
        let index = indexPath.row
        let task = alltask![index]
        taskCell.nameText.text = task.name
        taskCell.descriptionText.text = task.quickDes
        taskCell.expText.text = "\(task.expPoints ?? 0) exp"
        taskCell.reminderText.text = task.reminder
        taskCell.priorityText.text = taskCell.formatPriority(priority: task.priority)
        
        let imageIcon = UIImage(systemName: "circle")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
        taskCell.imageView?.image = imageIcon
        
        return taskCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        let date = dates[sectionIndex]
        let outputDate = formatDate(date)
        return outputDate
    }

}
