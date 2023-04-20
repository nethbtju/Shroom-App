//
//  BreakdownViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 20/4/2023.
//

import UIKit
import Firebase

class BreakdownViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentChar: Character?
    
    var currentPlayer: User?

    @IBOutlet weak var playerNameLabel: UILabel!
    
    @IBOutlet weak var shroomNameLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var hpLabel: UILabel!
    
    @IBOutlet weak var expLabel: UILabel!
    
    @IBOutlet weak var hpProgressBar: UIProgressView!
    
    @IBOutlet weak var expProgressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // Lets assume for now the user has JUST set their things up and the current character is in current Char variable
        currentChar = databaseController?.currentCharacter
    }
    
    func showCharacter(char: Character?){
        
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
