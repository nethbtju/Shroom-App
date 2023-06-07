//
//  CompleteTaskViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import UIKit

class CompleteTaskViewController: UIViewController, DatabaseListener, CurrentTaskDelegate {
    
    var badges: [Badge] = []
    
    var task: TaskItem?
    
    var currentCharacter: Character?
    
    var taskList: [TaskItem] = []
    
    var progress: [String : Int] = [:]
    
    var inventory: Inventory?
    
    var allBadges: [Badge] = []
    
    var listenerType = ListenerType.all
    
    let progressView = CircularProgressBarView(frame: CGRect(x: 0, y: -100, width: 300, height: 300), lineWidth: 15, rounded: false)
    
    weak var databaseController: DatabaseProtocol?
    
    var time: Int?
    
    var timer: Timer!
    
    var timeRemaining: Int?
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func goBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var taskTitle: UILabel!
    
    @IBOutlet weak var countDown: UILabel!
    
    @IBOutlet weak var timerSet: UIDatePicker!
    
    @IBOutlet weak var buttonName: UIButton!
    
    @IBOutlet weak var completeTaskName: UIButton!
    
    @IBAction func completeTaskButton(_ sender: Any) {
        if completeTask(){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func currentTaskIs(_ task: TaskItem) -> Bool {
        self.task = task
        return true
    }
    
    func setUpTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    func pauseTimer(){
        timer.invalidate()
    }
    
    func completeTask() -> Bool{
        guard let timeLeft = timeRemaining, let totalTime = time, let exp = task?.expPoints, let currentTask = task, let user = databaseController?.thisUser, let char = currentCharacter, let thisUser = databaseController?.currentUser?.uid else {
            return false
        }
        
        let subPercent = 1 - (timeLeft/totalTime)
        let earnedExp = exp * Int32(subPercent)
        currentCharacter?.exp! += earnedExp
        databaseController?.updateCharacterStats(char: char, user: (databaseController?.currentUser!.uid)!)
        databaseController?.removeTaskFromList(task: currentTask, user: user)
        databaseController?.deleteTask(task: currentTask)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let currentDateString: String = dateFormatter.string(from: Date())
        databaseController?.addCompletedTaskToProgress(date: currentDateString, user: thisUser)
        let _ = databaseController?.updateInventoryTasks()
        checkUserBadges()
        return true
    }
    
    func checkUserBadges(){
        guard let currentUserPoints = inventory?.tasksCompleted, let inv = inventory, let database = databaseController else {
            print("Could not parse user tasks completed")
            return
        }
        for badge in allBadges {
            if currentUserPoints >= badge.badgeType && badges.contains(badge) == false {
                if database.addBadgeToInventory(badge: badge, inventory: inv) {
                    print("Badge added to inventory")
                    database.cleanup()
                }
            }
        }
    }
    
    @objc func step(){
        if timeRemaining! > 0 {
            timeRemaining! -= 1
        } else {
            timer.invalidate()
            timeRemaining = Int(progressView.timeToFill)
        }
        countDown.text = "\(timeRemaining ?? 0)"
        
        if timeRemaining == 0{
            if completeTask(){
                _ = navigationController?.popViewController(animated: true)
            }
            
        }
                
    }
    
    @IBAction func setTimerButton(_ sender: Any) {
        time = Int(timerSet.countDownDuration)
        backButton.isHidden = true
        if buttonName.titleLabel?.text == "Start Timer"{
            let time = timerSet.countDownDuration
            progressView.timeToFill = time
            progressView.progress = 1
            buttonName.setTitle("Stop Timer", for: UIControl.State.normal)
            timerSet.isHidden = true
            countDown.isHidden = false
            timeRemaining = Int(progressView.timeToFill)
            
            // setting up the timer
            setUpTimer()
        } else {
            progressView.progress = 0
            progressView.timeToFill = Double(time! -  timeRemaining!)
            buttonName.setTitle("Start Timer", for: UIControl.State.normal)
            pauseTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonName.tintColor = UIColor(named: "CoralColor")
        completeTaskName.tintColor = UIColor(named: "LilacColor")
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        progressView.progressColor = UIColor(named: "LilacColor")!
        progressView.trackColor = .lightGray
        progressView.timeToFill = 0
        progressView.center = view.center
        view.addSubview(progressView)
        progressView.progress = 0
        
        countDown.isHidden = true
        
        guard let task = self.task else{
            return
        }
        taskTitle.text = task.name
        currentCharacter = databaseController?.currentCharacter
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        self.allBadges = badges
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        self.inventory = inventory
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        self.progress = progress
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        taskList = tasks
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        //
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
