//
//  AddUnitViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 25/5/2023.
//

import UIKit

class AddUnitViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var listName: UITextField!
    
    @IBOutlet weak var unitCode: UITextField!
    
    var listColour = UIColor.systemBlue
    
    var selected: UIButton!
    
    @IBOutlet weak var blueBtn: UIButton!
    
    @IBAction func selectBlue(_ sender: Any) {
        setCurrent(button: blueBtn)
    }
    
    @IBOutlet weak var tealBtn: UIButton!
    
    
    @IBAction func selectTeal(_ sender: Any) {
        setCurrent(button: tealBtn)
    }
    
    @IBOutlet weak var greenBtn: UIButton!
    
    @IBAction func selectGreen(_ sender: Any) {
        setCurrent(button: greenBtn)
    }
    
    @IBOutlet weak var yellowBtn: UIButton!
    
    @IBAction func selectYellow(_ sender: Any) {
        setCurrent(button: yellowBtn)
    }
    
    @IBOutlet weak var orangeBtn: UIButton!
    
    @IBAction func selectOrange(_ sender: Any) {
        setCurrent(button: orangeBtn)
    }
    
    @IBOutlet weak var pinkBtn: UIButton!
    
    @IBAction func selectPink(_ sender: Any) {
        setCurrent(button: pinkBtn)
    }
    
    @IBOutlet weak var redBtn: UIButton!
    
    @IBAction func selectRed(_ sender: Any) {
        setCurrent(button: redBtn)
    }
    
    @IBOutlet weak var violetBtn: UIButton!
    
    @IBAction func selectViolet(_ sender: Any) {
        setCurrent(button: violetBtn)
    }
    
    @IBOutlet weak var purpleBtn: UIButton!
    
    @IBAction func selectPurple(_ sender: Any) {
        setCurrent(button: purpleBtn)
    }
    
    @IBOutlet weak var greyBtn: UIButton!
    
    @IBAction func selectGrey(_ sender: Any) {
        setCurrent(button: greyBtn)
        
    }
    
    @IBOutlet weak var drkgreyBtn: UIButton!
    
    @IBAction func selectDrkGrey(_ sender: Any) {
        setCurrent(button: drkgreyBtn)
        
    }
    
    @IBOutlet weak var blackBtn: UIButton!
    
    @IBAction func selectBlack(_ sender: Any) {
        setCurrent(button: blackBtn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // Sets the current selected button as a default selection
        selected = blueBtn
        blueBtn.layer.borderWidth = 2
        blueBtn.layer.cornerRadius = 20
        blueBtn.layer.borderColor = UIColor(named: "LilacColor")?.cgColor
    }
    
    /// Set the current selection button with a blue ring around it to show it is currently selected
    ///
    /// - Parameters: button: UIButton - the selected button
    func setCurrent(button: UIButton){
        selected.layer.borderWidth = 0
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor(named: "LilacColor")?.cgColor
        selected = button
        listColour = button.tintColor!
    }
    
    // Cancel the adding buttons
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Creates a new list button when the user clicks to add a new list to the database controller
    @IBAction func createNewList(_ sender: Any) {
        guard let list = listName.text, list.isEmpty == false else{
            displayMessage(title: "Error", message: "Please a list name")
            return
        }
        
        guard let code = unitCode.text, code.isEmpty == false else{
            displayMessage(title: "Error", message: "Please a unit code")
            return
        }
        
        guard let user = databaseController?.currentUser?.uid else {
            return
        }
        
        guard let unit = databaseController?.addUnit(code: code, name: list, color: self.getIndex(color: listColour)) else {
            print("Could not create list sucessfully")
            return
        }
        let _ = databaseController?.addUnitToList(unit: unit, user: user)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Gets the index of the colour chosen to store in the firebase
    ///
    /// - Parameters: color - UIColor that needs to be converted to an integer
    func getIndex(color: UIColor) -> Int{
        var colour: Int
        switch color {
        case .systemBlue:
            colour = 0
        case .systemTeal:
            colour = 1
        case .systemGreen:
            colour = 2
        case .systemYellow:
            colour = 3
        case .systemOrange:
            colour = 4
        case .systemPink:
            colour = 5
        case .systemRed:
            colour = 6
        case .systemPurple:
            colour = 7
        case .systemIndigo:
            colour = 8
        case .systemGray:
            colour = 9
        case .gray:
            colour = 10
        case .black:
            colour = 11
        default:
            colour = 0
        }
        return colour
    }
    
}
