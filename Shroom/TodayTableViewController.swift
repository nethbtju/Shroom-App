//
//  TodayTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 17/5/2023.
//

import UIKit

class TodayTableViewController: UITableViewController, DatabaseListener {
    func onListChange(change: DatabaseChange, unitList: [String : [TaskItem]]) {
        // do nothing
    }
    
    var listenerType = ListenerType.task
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortedTasks = allTasks.sorted(by: {$0.dueDate! < $1.dueDate!})
        getTodayTasks()
        tableView.reloadData()
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    func stripTime(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func getTodayTasks(){
        var currentDateCheck = true
        var currentIndex = 0
        while currentDateCheck {
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
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
        return todayTasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        if todayTasks.isEmpty{
            cell.nameText.text = "No Tasks Due Today"
        } else{
            let task = todayTasks[indexPath.row]
            cell.nameText.text = task.name
            cell.descriptionText.text = task.quickDes
            cell.priorityText.text = cell.formatPriority(priority: task.priority)
            cell.expText.text = "\(task.expPoints ?? 0) exp"
            cell.reminderText.text = task.reminder
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        return formatDate(currentDate)
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
