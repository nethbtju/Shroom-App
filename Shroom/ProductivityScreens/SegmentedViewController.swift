//
//  SegmentedViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 3/6/2023.
//

import UIKit

/// Allows the productivity pages to be switches using a segmented control
class SegmentedViewController: UIViewController {

    @IBOutlet weak var productivitySegment: UIView!
    
    @IBOutlet weak var badgesSegment: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    ///When the user clicks either one of the segments, it makes that page the alpha and hides the other page
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            productivitySegment.alpha = 1
            badgesSegment.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            productivitySegment.alpha = 0
            badgesSegment.alpha = 1
        }
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
