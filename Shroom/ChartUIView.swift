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
