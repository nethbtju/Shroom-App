//
//  AddNewTask.swift
//  Shroom
//
//  Created by Neth Botheju on 27/5/2023.
//

import Foundation
import UIKit

/// Shows the view controller in a customised half sheet over the current view
///
/// - Parameters: controller: UIViewController - The current view controller that the sheet needs to appear over
///
func showMyViewControllerInACustomizedSheet(controller: UIViewController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "addTaskController")
    if let presentationController = vc.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
    controller.present(vc, animated: true)
}

/// Shows the screen to complete tasks
///
/// - Parameters: controller: UIViewController - The current view controller that the sheet needs to appear over
///               newVC: UIViewController -  The controller that needs to appear modally over the other
///
func showTaskCompletionScreen(controller: UIViewController, newVC: UIViewController) {
    let vc = newVC
    vc.modalPresentationStyle = .fullScreen
    controller.present(vc, animated: true)
}
