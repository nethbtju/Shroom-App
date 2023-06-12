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
    
    /// Delegate protocol that tells the complete task screen what task is being completed
    func currentTaskIs(_ task: TaskItem) -> Bool {
        self.task = task
        return true
    }
    
    /// Sets up the timer
    func setUpTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    /// Pauses the timer
    func pauseTimer(){
        timer.invalidate()
    }
    
    /// When a task is completed, it calculates the earned exp from that task depending on how much of that set time was spent on that task from the overall exp that task can gain.
    ///
    /// It will then update the characters status accordingly and remove the task from the tasklist. The function will then add that completed number as an increment to the user's
    /// total completed tasks in the core data.
    ///
    /// It will then pause the time and check if the user has earned any badges from that completed task
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
        pauseTimer()
        checkUserBadges()
        return true
    }
    
    /// It will check if the user has earned any badges by checking all badges point system and comparing it to the user's total completed tasks.
    /// If a user has earned a badge, it will add it to the user's inventory using the core data functions
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
    
    /// This function will increment the timer by 1 second each iteration. It alos formats what it shown on the timer screen and checks if the
    /// timer is over.
    @objc func step(){
        if timeRemaining! > 0 {
            timeRemaining! -= 1
        } else {
            timer.invalidate()
            timeRemaining = Int(progressView.timeToFill)
        }
        
        guard let time = timeRemaining else {
            print("Could not convert time")
            return
        }
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        var text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        
        countDown.text = "\(text)"
        
        if time == 0{
            if completeTask(){
                self.dismiss(animated: true, completion: nil)
            }
            
        }
                
    }
    
    /// Once the user has picked a time to set for this task, they can begin working on the task while the timer actively runs.
    /// If they choose to start the timer, they cannot go back to the task screen unless they finish the task or end it manually
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
            progressView.progress = Float(time! -  timeRemaining!)
            progressView.timeToFill = 0
            buttonName.setTitle("Start Timer", for: UIControl.State.normal)
            pauseTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonName.tintColor = UIColor(named: "SkyColor")
        completeTaskName.tintColor = UIColor(named: "LilacColor")
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Initial set up of the progress bar view
        progressView.progressColor = UIColor(named: "LilacColor")!
        progressView.trackColor = .lightGray
        progressView.timeToFill = 0
        progressView.center = view.center
        view.addSubview(progressView)
        progressView.progress = 0
        
        // hide the countdown
        countDown.isHidden = true
        
        guard let task = self.task else{
            return
        }
        
        // Set the task title
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
    
    func onGuildChange(change: DatabaseChange, guild: [Character]) {
        // do nothing
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
