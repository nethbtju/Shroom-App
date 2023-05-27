//
//  UpcomingViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 16/5/2023.
//

import UIKit

class UpcomingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener  {
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    @IBAction func addTaskButton(_ sender: Any) {
        showMyViewControllerInACustomizedSheet(controller: self)
    }
    
    var listenerType = ListenerType.task
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        allTasks = tasks
        sortedByDateTasks = allTasks.sorted(by: {$0.dueDate! < $1.dueDate!})
        splitByDate()
        reloadInputViews()
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // none
    }
    
    let CELL_TASKS = "taskCell"
    
    var allTasks: [TaskItem] = []
    
    var sortedByDateTasks: [TaskItem] = []
    
    var dates: [String] = []
    
    var allDates: [String: [TaskItem]] = [:]
    
    func splitByDate(){
        var counter = 5
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        
        for item in sortedByDateTasks{
            var date = inputFormatter.string(from: item.dueDate!)
            
            if allDates.contains(where: {$0.key == date}){
                var dateList = allDates[date]
                dateList?.append(item)
                allDates.updateValue(dateList!, forKey: date)
                
            } else if counter != 0 {
                allDates[date] = [item]
                dates.append(date)
                counter -= 1
            }
        }
        
    }
    
    weak var databaseController: DatabaseProtocol?

    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    /**
     Returns 5 sections for the 5 day upcoming view it will show
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = allDates.count
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var index = section
        var tasks_for_day = allDates[dates[section]]
        return tasks_for_day!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASKS, for: indexPath) as! TaskTableViewCell
        let date = dates[indexPath.section]
        let alltask = allDates[date]
        var index = indexPath.row
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
    
    func formatDate(_ today:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = dateFormatter.date(from: today) else {
            return "Cannot Print Date"
        }
        dateFormatter.dateFormat = "E"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd"
        let dayOfMonth = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        
        return "\(dayOfTheWeekString) • \(dayOfMonth) • \(monthString) • \(yearString)"
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
