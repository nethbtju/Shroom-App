//
//  ViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 8/4/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

/// Displays an error message for any user inputs when it does not meet the criteria
extension UIViewController {
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    
}

