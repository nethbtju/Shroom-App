//
//  ProductivityChartViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 27/5/2023.
//

import UIKit
import SwiftUI
import Charts

class ProductivityChartViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.all
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        //
    }
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
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
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        progressList = progress
        getLast7Days()
        setupProgressChart(weeklydata: progressList)
        setUpChart(data: data)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let currentDateString: String = dateFormatter.string(from: Date())
        guard let tasksCompletedToday = progressList[currentDateString] else {
            return
        }
        let total = 5.0
        var barProgress = (Double(tasksCompletedToday)/total)
        progressViewBar.progress = Float(barProgress)
        tasksCompletedLabel.text = "Completed \(tasksCompletedToday)/5 Tasks"
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        //
    }
    
    var days: [String] = []
    
    func getLast7Days(){
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        for _ in 1 ... 7 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let currentDateString: String = dateFormatter.string(from: date)
            days.append(currentDateString)
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!
        }
    }
    
    var progressList: [String: Int] = [:]
    
    var data: [WeeklyProgress] = []
    
    var tasksCompletedToday: Int?
    
    func setupProgressChart(weeklydata: [String: Int]){
        for day in days {
            data.append(.init(dayOfWeek: day, taskCount: progressList[day]!))
        }
        data = data.reversed()
    }
    
    @IBOutlet weak var tasksCompletedLabel: UILabel!
    
    @IBOutlet weak var expEarned: UILabel!
    
    @IBOutlet weak var leadingBar: UILabel!
    
    func setUpChart(data: [WeeklyProgress]){
        
        let chart = ChartUIView(data: data)
        
        let controller = UIHostingController(rootView: chart)
        
        guard let chartView = controller.view else {
            return
        }
        
        view.addSubview(chartView)
        addChild(controller)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
        constant: 22.0),
        chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
        constant: -20.0),
        chartView.topAnchor.constraint(equalTo: leadingBar.bottomAnchor, constant: 10.0)
        ])
    }
    
    @IBOutlet weak var progressView: UIView!
    
    let progressViewBar = CircularProgressBarView(frame: CGRect(x: 5, y: 5, width: 220, height: 220), lineWidth: 30, rounded: false)
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var chartViewSpace: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        progressViewBar.progressColor = UIColor(named: "LilacColor")!
        progressViewBar.trackColor = .systemGray6
        progressViewBar.timeToFill = 0
        progressView.center = progressViewBar.center
        progressView.addSubview(progressViewBar)
        
        //getLast7Days()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
