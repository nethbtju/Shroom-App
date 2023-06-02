//
//  WeeklyProgress.swift
//  Shroom
//
//  Created by Neth Botheju on 3/6/2023.
//

import Foundation

struct WeeklyProgress: Identifiable {
    var dayOfWeek: Int
    var taskCount: Double
    var id = UUID()
}
