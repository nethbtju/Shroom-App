//
//  CompleteTaskViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import UIKit

class CompleteTaskViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.all
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        taskList = tasks
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        currentCharacter = character
    }
    
    var task: TaskItem?
    
    var currentCharacter: Character?
    
    var taskList: [TaskItem] = []
    
    let progressView = CircularProgressBarView(frame: CGRect(x: 0, y: -100, width: 300, height: 300), lineWidth: 15, rounded: false)
    
    @IBOutlet weak var countDown: UILabel!
    
    @IBOutlet weak var timerSet: UIDatePicker!
    
    @IBOutlet weak var buttonName: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    
    var time: Int?
    
    var timer: Timer!
    
    var timeRemaining: Int?
    
    @IBAction func completeTaskButton(_ sender: Any) {
        if completeTask(){
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func setUpTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    func pauseTimer(){
        timer.invalidate()
    }
    
    func completeTask() -> Bool{
        guard let timeLeft = timeRemaining, let totalTime = time, let exp = task?.expPoints else {
            return false
        }
        
        var subPercent = 1 - (timeLeft/totalTime)
        
        var earnedExp = exp * Int32(subPercent)
        currentCharacter?.exp! += earnedExp
        return true
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
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        progressView.progressColor = UIColor(named: "LilacColor")!
        progressView.trackColor = .lightGray
        progressView.timeToFill = 0
        progressView.center = view.center
        view.addSubview(progressView)
        progressView.progress = 0
        self.navigationItem.title = task?.name
        self.navigationItem.backButtonTitle = "Back"
        countDown.isHidden = true
        
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
