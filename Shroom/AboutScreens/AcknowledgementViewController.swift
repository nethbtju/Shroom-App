//
//  AcknowledgementViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 11/6/2023.
//

import UIKit
protocol AboutPageDelegate: AnyObject {
    func didSelectCell(withContent content: String)
}

class AcknowledgementViewController: UIViewController {
    
    var delegate: AboutPageDelegate?
    
    var setText: String?
    
    var content: String?
    
    @IBOutlet weak var textLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Depending on the content sent through the delegate, the
        // view controller will set up one of the following functions to show
        // on the table
        switch content {
        case "firebase":
            printFirebaseAcknowledgement()
        case "siesta":
            printSiestaAcknowledgement()
        case "tutorial":
            printTutorialAcknowledgement()
        case "image":
            printImageAcknowledgement()
        default:
            setText = "Default acknowledgement"
        }
        textLabel.text = setText
    }
    
    /// Shows acknowledgement for the firebase
    func printFirebaseAcknowledgement() {
        setText = "These Google Cloud Platform Terms of Service (together, the 'Agreement') are entered into by Google and the entity or person agreeing to these terms ('Customer') and govern Customer's access to and use of the Services. 'Google' has the meaning given at https://cloud.google.com/terms/google-entity. \nThis Agreement is effective when Customer clicks to accept it (the 'Effective Date'). \n\nIf you are accepting on behalf of Customer, you represent and warrant that \n\n(i) you have full legal authority to bind Customer to this Agreement; \n\n(ii) you have read and understand this Agreement; \n\nand (iii) you agree, on behalf of Customer, to this Agreement."
    }

    /// Shows acknowledgement for the Siesta API
    func printSiestaAcknowledgement() {
        setText = "Copyright (c) 2018 Bust Out Solutions, Inc. http://bustoutsolutions.com Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: \n\n The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. \n\n THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    }

    /// Shows acknowledgement for the tutorials and code used
    func printTutorialAcknowledgement() {
        setText = "Delegates and Protocols: Sean Allen on YouTube (https://www.youtube.com/watch?v=qiOKO8ta1n4) \n\n\n SwiftUI Bar Chart with Customizations: Sean Allen on Youtube (https://www.youtube.com/watch?v=4utsyqhnS4g) \n\n\n Calendar Days: Martin R on StackOverflow (https://stackoverflow.com/questions/26996330/swift-get-last-7-days-starting-from-today-in-array)\n\n\n Circular Progress Bar: Sree on Medium (https://medium.com/@imsree/custom-circular-progress-bar-in-ios-using-swift-4-b1a9f7c55da)\n"
    }
    
    /// Shows acknowledgement for the Images used
    func printImageAcknowledgement() {
        setText = "Battle Backgrounds by Pikatchoum on fiverr (https://www.fiverr.com/pikatchoum/draw-a-pixel-pokemon-battle-background)\n\n\n Medal Icon on Vecteezy (https://www.vecteezy.com/free-vector/medal-icon)"
    }

}
