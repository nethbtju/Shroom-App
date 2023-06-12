//
//  PickCharacterViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit
import Firebase

class PickCharacterViewController: UIViewController {
    
    var chosenCharName: String?
    var chosenImage: String?
    var image: UIImage?
    
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?

    @IBOutlet weak var welcomeLabel: UILabel?
    
    // When clicked will allow the chosen character to be parsed into firebase
    @IBAction func chooseCharacter(_ sender: Any) {
        guard let chosenChar = chosenCharName, chosenChar.isEmpty == false, let charImage = chosenImage, charImage.isEmpty == false else{
            displayMessage(title: "No Starter Shroom Selected", message: "Please select a starter shroom!")
            return
        }
        databaseController?.createNewStarter(charName: chosenChar, level: 1, exp: 0, health: 100, charImageName: charImage)
        databaseController?.currentCharImage = image
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet weak var buttonText: UIButton!
    
    @IBOutlet weak var purpleShroom: UIImageView!
    
    @IBOutlet weak var pinkShroom: UIImageView!
    
    @IBOutlet weak var blueShroom: UIImageView!
    
    @IBOutlet weak var redShroom: UIImageView!
    
    @IBOutlet weak var chosenChar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authController = Auth.auth()
        
        // Setting up the tap gestures for each image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        
        // add it to the image view
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
    }
    
    /// Will register an image that has been tapped and display that image on the screen as the chosen character
    /// The code was referenced and modified using the answer provided on StackOverflow by Arbitur on Jun 20 2015
    /// (Link: https://stackoverflow.com/questions/30958745/how-to-detect-which-image-has-been-tapped-in-swift)
    ///
    ///  - Parameters: gesture: The type of gesture that was conducted
    ///
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            let imageTag = gesture.view!.tag
            switch imageTag {
            case 0:
                image = redShroom.image!
                self.chosenCharName = "Red Shroom"
                self.chosenImage = "redShroom"
            case 1:
                image = blueShroom.image!
                self.chosenCharName = "Blue Shroom"
                self.chosenImage = "blueShroom"
            case 2:
                image = pinkShroom.image!
                self.chosenCharName = "Pink Shroom"
                self.chosenImage = "pinkShroom"
            case 3:
                image = purpleShroom.image!
                self.chosenCharName = "Purple Shroom"
                self.chosenImage = "purpleShroom"
            default:
                image = redShroom.image!
            }
            chosenChar.image = image
            buttonText.setTitle("Choose \(chosenCharName!)", for: buttonText.state)
        }
    }

}
