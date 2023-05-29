//
//  CompleteTaskViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import UIKit

class CompleteTaskViewController: UIViewController {
    
    var task: TaskItem?
    
    let progressView = CircularProgressBarView(frame: CGRect(x: 0, y: -100, width: 300, height: 300), lineWidth: 15, rounded: false)
    
    @IBOutlet weak var countDown: UILabel!
    
    @IBOutlet weak var timerSet: UIDatePicker!
    
    @IBOutlet weak var buttonName: UIButton!
    
    var timer: Timer!
    
    var timeRemaining: Int?
    
    func setUpTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    func pauseTimer(){
        timer.invalidate()
    }
    
    @objc func step(){
        if timeRemaining! > 0 {
            timeRemaining! -= 1
        } else {
            timer.invalidate()
            timeRemaining = Int(progressView.timeToFill)
        }
        countDown.text = "\(timeRemaining ?? 0)"
    }
    
    @IBAction func setTimerButton(_ sender: Any) {
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
            progressView.progress = timeRemaining
            progressView.timeToFill = 0
            buttonName.setTitle("Start Timer", for: UIControl.State.normal)
            pauseTimer()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
