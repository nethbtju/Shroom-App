//
//  ChooseNameViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit
import Firebase

class ChooseNameViewController: UIViewController {
    
    @IBOutlet weak var playerName: UITextField!
    
    var authController: Auth?
    
    weak var databaseController: DatabaseProtocol?
    
    /// Button when clicked allows the user to pick their designated name from the outlets they have entered details in. This
    /// action will check if the names as appropriate and if not display an error message
    ///
    /// - Parameters: controller: UIViewController - The current view controller that the sheet needs to appear over
    ///
    @IBAction func chooseName(_ sender: Any) {
        guard let name = playerName.text, name.isEmpty == false else {
            displayMessage(title: "Invalid Name", message: "Nickname cannot be empty")
            return
        }
        
        let changeRequest = authController?.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            print("Display Name change failed with error \(String(describing: error))")
        }
        self.performSegue(withIdentifier: "chooseCharSegue", sender: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        authController = Auth.auth()
    }
}
