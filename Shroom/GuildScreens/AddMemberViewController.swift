//
//  AddMemberViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 10/6/2023.
//

import UIKit

class AddMemberViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var uniqueID: UILabel!
    
    @IBOutlet weak var addingID: UITextField!
    
    /// Allows the user to add a member using a unique ID that users may share with each other. If it is not a valid ID, the controller will display an error message
    @IBAction func addMemberButton(_ sender: Any) {
        guard let id = addingID.text, id.isEmpty == false, let database = databaseController else {
            displayMessage(title: "Invalid UniqueID Entered", message: "Please enter a valid UniqueID valid")
            return
        }
        if database.addCharacterToGuild(uniqueID: id) {
            _ = navigationController?.popViewController(animated: true)
        } else {
            displayMessage(title: "Invalid UniqueID Entered", message: "Please enter a valid UniqueID valid")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        uniqueID.text = databaseController?.currentUser?.uid
        // Do any additional setup after loading the view.
        background.layer.cornerRadius = 5
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
