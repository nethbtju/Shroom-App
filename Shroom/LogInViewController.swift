//
//  LogInViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import Firebase

class LogInViewController: UIViewController, DatabaseListener{

    var authController: Auth?
    var authHandle: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?
    
    var listenerType = ListenerType.character
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    /// Allows the user to log into an account they have already created. This function will effectively check if the user's email and password is valid
    /// and will display error messages if not. If they are valid it will attempt to log into the firebase authentication
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
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do Nothing
    }
    
    /// If there exists a character it will pop the controller back to the root of it to allow the game to segue into the main screen
    func onCharacterChange(change: DatabaseChange, character: Character) {
        if databaseController?.currentCharacter?.charName != nil{
            navigationController?.popToRootViewController(animated: true)
        }
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
