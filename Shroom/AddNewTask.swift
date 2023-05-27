//
//  AddNewTask.swift
//  Shroom
//
//  Created by Neth Botheju on 27/5/2023.
//

import Foundation
import UIKit

func showMyViewControllerInACustomizedSheet(controller: UIViewController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "addTaskController")
    if let presentationController = vc.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
    controller.present(vc, animated: true)
}
