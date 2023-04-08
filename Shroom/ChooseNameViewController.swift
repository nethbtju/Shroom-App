//
//  ChooseNameViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit

class ChooseNameViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType
    
    var currentPlayer = [Player]()
    
    func onPlayerChange(change: DatabaseChange, player: [Player]) {
        currentPlayer = player
    }
    
    func onCharacterChange(change: DatabaseChange, character: [Character]) {
        // do nothing
    }
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        // Do any additional setup after loading the view.
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
