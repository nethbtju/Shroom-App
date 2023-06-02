//
//  ProductivityChartViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 27/5/2023.
//

import UIKit

class ProductivityChartViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        //
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        //
    }
    
    func onProgressChange(change: DatabaseChange, progress: [Int]) {
        progressList = progress
        setupProgressChart(weeklydata: progressList)
    }
    
    func onBadgesChange(change: DatabaseChange, badges: [Int]) {
        //
    }
    
    var progressList: [Int] = []
    
    var data: [WeeklyProgress] = []
    
    func setupProgressChart(weeklydata: [Int]){
        for (index, days) in weeklydata.enumerated() {
            data.append(.init(dayOfWeek: index, taskCount: Double(days)))
        }
        
    }
    @IBOutlet weak var progressView: UIView!
    
    let progressViewBar = CircularProgressBarView(frame: CGRect(x: 12, y: 12, width: 250, height: 250), lineWidth: 30, rounded: false)
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var navigationTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle.text = "Productivity"
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        progressViewBar.progressColor = UIColor(named: "LilacColor")!
        progressViewBar.trackColor = .systemGray6
        progressViewBar.timeToFill = 0
        progressView.center = progressViewBar.center
        progressView.addSubview(progressViewBar)
        progressViewBar.progress = 0.6
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
