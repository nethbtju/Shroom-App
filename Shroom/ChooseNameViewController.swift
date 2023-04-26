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
    
    // TODO: Make sure to check database for existing name/id
    @IBAction func chooseName(_ sender: Any) {
        guard let name = playerName.text, name.isEmpty == false else {
            displayMessage(title: "Invalid Name", message: "Nickname cannot be empty")
            return
        }
        databaseController?.createNewUser(name: name)
        self.performSegue(withIdentifier: "chooseCharSegue", sender: nil)
    }
    
    weak var databaseController: DatabaseProtocol?
    
    var authHandle: AuthStateDidChangeListenerHandle?
    
    var authController: Auth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        authController = Auth.auth()
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authHandle = authController?.addStateDidChangeListener{ auth, user in
            if self.authController?.currentUser != nil {
                self.performSegue(withIdentifier: "mainScreenSegue", sender: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeStateDidChangeListener(authHandle!)
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
