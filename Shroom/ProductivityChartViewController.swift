//
//  ProductivityChartViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 27/5/2023.
//

import UIKit

class ProductivityChartViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var navigationTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle.text = "Productivity"
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
