//
//  SignUpViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    var authController: Auth?
    var authHandle: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    /// When the button is pressed it will check if the user entered sign up inputs are of valid nature and if not execute error
    /// messages according to such. If all inputs meet the standard it will attempt to create a new account for the user in the firebase
    /// authentication
    @IBAction func signUpAction(_ sender: Any) {
        guard let emailAdd = username.text, emailAdd.isEmpty == false else {
            displayMessage(title: "Invalid", message: "Please enter email address")
            return
        }
        guard let pass = password.text, pass.isEmpty == false else {
            displayMessage(title: "Invalid", message: "Please enter email address")
            return
        }
        
        if isValidEmail(emailAdd) != true {
            displayMessage(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        Task {
            try await databaseController?.createNewAccount(email: emailAdd, password: pass)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        authController = Auth.auth()
    }
    
    /// Checks if the user is already signed into an account, hence will segue to picking the name if they already have an account
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authHandle = authController?.addStateDidChangeListener{ auth, user in
            if self.authController?.currentUser != nil && self.authController?.currentUser?.isAnonymous == false {
                self.performSegue(withIdentifier: "pickNameSegue", sender: nil)
            }
        }
    }
    
    /// Makes the listeners disappear when the screen segues out of the controller
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeStateDidChangeListener(authHandle!)
    }
}
