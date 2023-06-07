//
//  AuthenticationViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?
    var authHandle: AuthStateDidChangeListenerHandle?
    var authController: Auth?
    
    var listenerType = ListenerType.character
    
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    
    func onInventoryChange(change: DatabaseChange, inventory: Inventory) {
        // do nothing
    }
    func onBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do nothing
    }
    
    func onProgressChange(change: DatabaseChange, progress: [String : Int]) {
        // do nothing
    }
    
    func onInventoryBadgeChange(change: DatabaseChange, badges: [Badge]) {
        // do nothing
    }
    
    /// Checks if the current user has a character chosen from the last segue. If so allows to segue into the main screen.
    ///
    /// - Parameters: change: DatabaseChange - Type of change the database is listening for
    ///               character: Character - The character that was selected as the starter
    ///
    func onCharacterChange(change: DatabaseChange, character: Character) {
        if databaseController?.currentCharacter?.charName != nil {
            self.performSegue(withIdentifier: "mainScreenSegue", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        authController = Auth.auth()
        
        // MARK: For testing purposes: Log out of firebase
        /*do {
            try authController?.signOut()
            print("User signed out sucessfully")
        }
        catch {
            print("User sign out failed with error \(String(describing: error))")
        }*/
    }

    /// Checks if the state of the authenicator is already logged into user and if so calls the set up user function to run and
    /// create the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        authHandle = authController?.addStateDidChangeListener{ auth, user in
            if self.authController?.currentUser != nil {
                Task {
                    try await self.databaseController?.setUpUser()
                }
            }
        }
    }
    
    /// When the view is about the disappear it will remove the active listeners from this screen
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeStateDidChangeListener(authHandle!)
        databaseController?.removeListener(listener: self)
    }

}
