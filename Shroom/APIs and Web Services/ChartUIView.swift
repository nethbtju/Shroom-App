//
//  ChartUIView.swift
//  Shroom
//
//  Created by Neth Botheju on 3/6/2023.
//

import Foundation
import SwiftUI
import Charts

struct WeeklyProgress: Identifiable {
    var dayOfWeek: String
    var taskCount: Int
    var id = UUID()
}

/// Creates the structure for the swift charts used to demonstrate the progress of the user each week.
/// This was referenced and modified code used from the FIT3178: iOS Development unit Week 9 Lab by Monash University
struct ChartUIView: View{
    
    public var barWidth = Double(1)
    
    var data: [WeeklyProgress] = [
    ]
    
    var body: some View {
        Chart(data) { progressData in
            BarMark(x: .value("Tasks Completed", progressData.taskCount),
                    y: .value("Day", progressData.dayOfWeek))
        }
        .foregroundStyle(Color.init(uiColor: UIColor(named: "SkyColor")!).gradient)
        .frame(height: 200)
    }
    
}
