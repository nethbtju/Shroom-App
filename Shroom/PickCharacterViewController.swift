//
//  PickCharacterViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit
import Firebase

class PickCharacterViewController: UIViewController, DatabaseListener {
    func onListChange(change: DatabaseChange, unitList: [String : [TaskItem]]) {
        // do nothing
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        // do nothing
    }
    
    var authController: Auth?

    @IBOutlet weak var welcomeLabel: UILabel?
    
    @IBAction func chooseCharacter(_ sender: Any) {
        guard let chosenChar = chosenCharName, chosenChar.isEmpty == false else{
            displayMessage(title: "No Starter Shroom Selected", message: "Please select a starter shroom!")
            return
        }
        databaseController?.createNewStarter(charName: chosenChar, level: 1, exp: 0, health: 100)
        databaseController?.currentCharImage = image
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet weak var buttonText: UIButton!
    
    @IBOutlet weak var purpleShroom: UIImageView!
    @IBOutlet weak var pinkShroom: UIImageView!
    @IBOutlet weak var blueShroom: UIImageView!
    @IBOutlet weak var redShroom: UIImageView!
    
    @IBOutlet weak var chosenChar: UIImageView!
    
    var listenerType = ListenerType.player
    
    var chosenCharName: String?
    
    var image: UIImage?
    
    func onCharacterChange(change: DatabaseChange, character: [Character]) {
        // do nothing
    }
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authController = Auth.auth()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
            // add it to the image view;
        redShroom.addGestureRecognizer(tapGesture1)
        redShroom.isUserInteractionEnabled = true
        
        blueShroom.addGestureRecognizer(tapGesture)
        blueShroom.isUserInteractionEnabled = true
        
        purpleShroom.addGestureRecognizer(tapGesture2)
        purpleShroom.isUserInteractionEnabled = true
         
        pinkShroom.addGestureRecognizer(tapGesture3)
        pinkShroom.isUserInteractionEnabled = true
         
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        welcomeLabel!.text = "Welcome, \(authController?.currentUser?.displayName ?? "Stranger!")"
        // Do any additional setup after loading the view.
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
            // if the tapped view is a UIImageView then set it to imageview
            if (gesture.view as? UIImageView) != nil {
                let imageTag = gesture.view!.tag
                switch imageTag {
                    case 0:
                        image = redShroom.image!
                        self.chosenCharName = "Red Shroom"
                    case 1:
                        image = blueShroom.image!
                        self.chosenCharName = "Blue Shroom"
                    case 2:
                        image = pinkShroom.image!
                        self.chosenCharName = "Pink Shroom"
                    case 3:
                        image = purpleShroom.image!
                        self.chosenCharName = "Purple Shroom"
                default:
                    image = redShroom.image!
                }
                chosenChar.image = image
                buttonText.setTitle("Choose \(chosenCharName!)", for: buttonText.state)
                //Here you can initiate your new ViewController
            }
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
