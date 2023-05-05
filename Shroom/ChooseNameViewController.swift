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
    
    // TODO: Make sure to check database for existing name/id
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
    
    weak var databaseController: DatabaseProtocol?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        authController = Auth.auth()
        // Do any additional setup after loading the view.
        
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
