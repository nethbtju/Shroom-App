//
//  TodayTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 17/5/2023.
//

import UIKit
import Siesta

class TodayTableViewController: UITableViewController, DatabaseListener {
    
    var holidays: [String] = []
    
    var currentDate = Date()
    
    var allTasks: [TaskItem] = []
    
    var sortedTasks: [TaskItem] = []
    
    var todayTasks: [TaskItem] = []
    
    var CELL_TASK = "taskCell"
    var CELL_NO = "noTaskCell"
    
    let SECTION_TASK = 0
    let SECTION_NO = 1
    
    weak var databaseController: DatabaseProtocol?
    
    var listenerType = ListenerType.task

    @IBOutlet weak var holidayLabel: UILabel!
    
    @IBOutlet weak var todayDate: UILabel!
    
    /// When add task button is clicked the page modallu shows the half sheet page to add tasks
    @IBAction func addTasks(_ sender: Any) {
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    /// Sets up the label for the current holiday that the API parses to the controller
    func setUpHoliday(){
        var hols = ""
        for dates in holidays {
            hols += " \(dates)"
        }
        holidayLabel.text = "\(hols) • Australia"
    }
    
    /// Fetches all the tasks that match the current date and puts them into the todayTasks list
    func getTodayTasks(){
        var currentDateCheck = true
        var currentIndex = 0
        let taskCount = allTasks.count
        while currentDateCheck && currentIndex < taskCount {
            guard let date = sortedTasks[currentIndex].dueDate else {
                print("Could not retrieve due take from sorted tasks")
                return
            }
            if stripTime(from: date) != stripTime(from: currentDate) {
                currentDateCheck = false
                return
            } else{
                let item = sortedTasks[currentIndex]
                todayTasks.append(item)
                currentIndex += 1
            }
        }
    }
    
    /// Allows the date object from the due date be stripped into its date to compare with todays date string
    ///
    /// - Parameters: originalDate: Date - The date from the task object
    func stripTime(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        guard let date = Calendar.current.date(from: components) else {
            print("Could not retrieve calender current date")
            return Date()
        }
        return date
    }
    
    /// Formats the date to show on the view controller date label
    ///
    /// - Parameters: today: Date - Today's date to show up on the label
    func formatDate(_ today: Date) -> String? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd"
        let dayOfMonth = dateFormatter.string(from: today)

        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: today)
        
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: today)
        
        return "Today • \(dayOfMonth) • \(monthString) • \(yearString)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        todayDate.text = formatDate(currentDate)
        
        /// Adds an observer to the holiday API that shows the holidays on that particular day
        HolidaysAPI.holidaysResource.addObserver(self)
        HolidaysAPI.holidaysResource.loadIfNeeded()
        
    }
    
    /// When the tasks get updated, it shows the changes and updates the table to reflect the tasks accordingly
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortedTasks = allTasks.sorted(by: {$0.dueDate! < $1.dueDate!})
        getTodayTasks()
        tableView.reloadData()
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_NO:
            return 1
        case SECTION_TASK:
            return todayTasks.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TASK{
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
            let task = todayTasks[indexPath.row]
            cell.nameText.text = task.name
            cell.descriptionText.text = task.quickDes
            cell.priorityText.text = cell.formatPriority(priority: task.priority)
            cell.expText.text = "\(task.expPoints ?? 0) exp"
            cell.reminderText.text = task.reminder
            
            guard let colour = UIColor(named: "LilacColor") else {
                print("Could not retrieve Lilac Color")
                return cell
            }
            
            let imageIcon = UIImage(systemName: "circle")?.withTintColor(colour, renderingMode: .alwaysOriginal)
            cell.imageView?.image = imageIcon
            
            return cell
            
        } else if indexPath.section == SECTION_NO && todayTasks.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noTaskCell", for: indexPath) as! TaskTableViewCell
            cell.noTasks.text = "There are no tasks today. Add them using the + button!"
            return cell
            
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noTaskCell", for: indexPath) as! TaskTableViewCell
            cell.noTasks.text = ""
            return cell
            
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

}

extension TodayTableViewController: ResourceObserver {
    
    /// Gets the holiday dates of all the holdiays in the current year and checks if today's date has anything special to it
    /// if it does it appends to the holidays string
    ///
    /// - Parameters: resource: Resource - The holiday API resource provided usign Siesta
    ///               event: Resource Event - call to the API to retrieve dates
    ///
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        let holidaysName = resource.jsonArray
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["name"] as? String }
        
        let holidaysDate = resource.jsonArray
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["date"] as? String }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let today = inputFormatter.string(from: currentDate)
        
        for (index, item) in holidaysDate.enumerated() {
            if item == today {
                self.holidays.append(holidaysName[index])
            }
        }
        // If there is a holiday for today then it will update the label otherwise keep as default
        if holidays.isEmpty == false{
            setUpHoliday()
        }
    }
}
