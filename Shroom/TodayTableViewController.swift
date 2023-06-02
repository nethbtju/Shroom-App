//
//  TodayTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 17/5/2023.
//

import UIKit
import Siesta

class TodayTableViewController: UITableViewController, DatabaseListener {
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    @IBOutlet weak var holidayLabel: UILabel!
    
    var holidays: [String] = []
    
    @IBOutlet weak var todayDate: UILabel!
    
    var listenerType = ListenerType.task
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortedTasks = allTasks.sorted(by: {$0.dueDate! < $1.dueDate!})
        getTodayTasks()
        tableView.reloadData()
    }
    
    @IBAction func addTasks(_ sender: Any) {
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    func onProgressChange(change: DatabaseChange, progress: [Int]) {
        //
    }
    
    func onBadgesChange(change: DatabaseChange, badges: [Int]) {
        //
    }
    func stripTime(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func setUpHoliday(){
        var hols = ""
        for dates in holidays {
            hols += " \(dates)"
        }
        holidayLabel.text = "\(hols) • Australia"
    }
    
    func getTodayTasks(){
        var currentDateCheck = true
        var currentIndex = 0
        var taskCount = allTasks.count
        while currentDateCheck && currentIndex < taskCount {
            var date = sortedTasks[currentIndex].dueDate
            if stripTime(from: date!) != stripTime(from: currentDate) {
                currentDateCheck = false
                return
            } else{
                var item = sortedTasks[currentIndex]
                todayTasks.append(item)
                currentIndex += 1
            }
        }
    }
    
    var currentDate = Date()
    
    var allTasks: [TaskItem] = []
    
    var sortedTasks: [TaskItem] = []
    
    var todayTasks: [TaskItem] = []
    
    var CELL_TASK = "taskCell"
    var CELL_NO = "noTaskCell"
    
    let SECTION_TASK = 0
    let SECTION_NO = 1
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        todayDate.text = formatDate(currentDate)
        
        HolidaysAPI.holidaysResource.addObserver(self)
        HolidaysAPI.holidaysResource.loadIfNeeded()
        
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
            
            let imageIcon = UIImage(systemName: "circle")?.withTintColor(UIColor(named: "LilacColor")!, renderingMode: .alwaysOriginal)
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
    
    func formatDate(_ today: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayOfTheWeekString = dateFormatter.string(from: today)
        
        dateFormatter.dateFormat = "dd"
        let dayOfMonth = dateFormatter.string(from: today)

        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: today)
        
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: today)
        
        return "Today • \(dayOfMonth) • \(monthString) • \(yearString)"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TodayTableViewController: ResourceObserver {
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
        if holidays.isEmpty == false{
            setUpHoliday()
        }
    }
}
