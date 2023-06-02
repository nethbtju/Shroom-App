//
//  AuthenticationViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 5/5/2023.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController, DatabaseListener {
    func onListChange(change: DatabaseChange, unitList: [Unit]) {
        // do nothing
    }
    var listenerType = ListenerType.character
    
    func onTaskChange(change: DatabaseChange, tasks: [TaskItem]) {
        // do nothing
    }
    
    func onProgressChange(change: DatabaseChange, progress: [Int]) {
        //
    }
    
    func onBadgesChange(change: DatabaseChange, badges: [Int]) {
        //
    }
    
    func onCharacterChange(change: DatabaseChange, character: Character) {
        if databaseController?.currentCharacter?.charName != nil {
            self.performSegue(withIdentifier: "mainScreenSegue", sender: nil)
        }
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
        /*do {
            try authController?.signOut()
            print("User signed out sucessfully")
        }
        catch {
            print("User sign out failed with error \(String(describing: error))")
        }*/
    }

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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeStateDidChangeListener(authHandle!)
        databaseController?.removeListener(listener: self)
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
