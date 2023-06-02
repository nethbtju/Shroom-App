//
//  LogInViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import Firebase

class LogInViewController: UIViewController, DatabaseListener{
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    func onProgressChange(change: DatabaseChange, progress: [Int]) {
        //
    }
    
    func onBadgesChange(change: DatabaseChange, badges: [Int]) {
        //
    }
    var listenerType = ListenerType.character
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do Nothing
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        if databaseController?.currentCharacter?.charName != nil{
            navigationController?.popToRootViewController(animated: true)
        }
    }

    var authController: Auth?
    
    var authHandle: AuthStateDidChangeListenerHandle?
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func logInAction(_ sender: Any) {
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
            try await databaseController?.logInToAccount(email: emailAdd, password: pass)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

}
