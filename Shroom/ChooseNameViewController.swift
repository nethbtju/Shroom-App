//
//  ChooseNameViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit

class ChooseNameViewController: UIViewController {
    
    @IBOutlet weak var playerName: UITextField!
    
    // TODO: Make sure to check database for existing name/id
    @IBAction func chooseName(_ sender: Any) {
        guard let name = playerName.text, name.isEmpty == false else {
            displayMessage(title: "Invalid Name", message: "Nickname cannot be empty")
            return
        }
        let player = databaseController?.addPlayer(name: name)
        databaseController?.currentPlayer = player
        navigationController?.popViewController(animated: true)
    }
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
