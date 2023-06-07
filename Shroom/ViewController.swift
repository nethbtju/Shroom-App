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


extension UIViewController {
    /// Displays an error message for any user inputs when it does not meet the criteria
    ///
    /// - Parameters: title: String - A title to what the error is about
    ///               message: String - The message displayed to the user about the error
    ///               
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    
    /// Checks if the email is a valid one using a regex check
    ///
    /// - Parameters: email: String - The user input email address
    ///
    /// - Returns: Bool - whether the email address was valid or not
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    /// Formats the date to show on the view controller date label
    ///
    /// - Parameters: today: Date - Today's date to show up on the label
    func formatDate(_ today:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = dateFormatter.date(from: today) else {
            return "Cannot Print Date"
        }
        dateFormatter.dateFormat = "E"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd"
        let dayOfMonth = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        
        return "\(dayOfTheWeekString) • \(dayOfMonth) • \(monthString) • \(yearString)"
    }
    
}

