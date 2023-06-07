//
//  TabBarViewController.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hides the back button on the tab bar view
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}
