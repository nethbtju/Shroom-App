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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authHandle = authController?.addStateDidChangeListener{ auth, user in
            if self.authController?.currentUser != nil && self.authController?.currentUser?.isAnonymous == false {
                self.performSegue(withIdentifier: "pickNameSegue", sender: nil)
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeStateDidChangeListener(authHandle!)
    }
}
