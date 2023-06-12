//
//  CurrentTaskDelegate.swift
//  Shroom
//
//  Created by Neth Botheju on 30/5/2023.
//

import Foundation
/// Delegate that shows the current selected task
protocol CurrentTaskDelegate: AnyObject {
    func currentTaskIs(_ task: TaskItem) -> Bool
}
