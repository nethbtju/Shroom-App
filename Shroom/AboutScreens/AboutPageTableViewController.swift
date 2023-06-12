//
//  AboutPageTableViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 11/6/2023.
//

import UIKit

class AboutPageTableViewController: UITableViewController, AboutPageDelegate {
    func didSelectCell(withContent content: String) {
        //
    }
    
    var parsedContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // checks the index row and sets the name of the cell as the corresponding name
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firebase", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Firebase Acknowledgement"
            cell.contentConfiguration = content
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "siesta", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Siesta Acknowledgement"
            cell.contentConfiguration = content
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorials", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Tutorials & Code Acknowledgement"
            cell.contentConfiguration = content
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Images Acknowledgement"
            cell.contentConfiguration = content
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
    IndexPath) {
        // Depending on the indexpath row, it sets the parse content variable
        // to the content that needs to the parse
        let cell = indexPath.row
        if cell == 0 {
            parsedContent = "firebase"
            
        } else if cell == 1 {
            parsedContent = "siesta"
            
        } else if cell == 2 {
            parsedContent =  "tutorial"
            
        } else {
            parsedContent =  "image"
        
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        // performs the segue to the acknowledgement page
        self.performSegue(withIdentifier: "refSegue", sender: nil)
    }
    
    /// When a segue begins to the acknowledgement page, the controller will parse the type of content
    /// that need to be dispalyed through the delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "refSegue" {
            let destination = segue.destination as! AcknowledgementViewController
            destination.delegate = self
            destination.content = parsedContent
        }
    }

}
