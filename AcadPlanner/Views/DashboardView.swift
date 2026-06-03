//
//  DashboardView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack
        {
            List
            {
                Section("Overview")
                {
                    DashboardCard(title: "Upcoming Tasks", value: "\(viewModel.upComingTasks.count)")
                    DashboardCard(title:"Pending Tasks", value: "\(viewModel.pendingTaskCount)")
                    DashboardCard(title:"Completed Tasks", value: "\(viewModel.completedTaskCount)")
                    DashboardCard(title:"Added to Calendar",value: "\(viewModel.calendarTaskCount)")
                }
                
                Section("Next Deadlines")
                {
                    ForEach(viewModel.upComingTasks)
                    {
                        task in VStack(alignment: .leading,spacing: 4)
                        {
                            Text(task.title)
                                .font(.headline)
                            
                            Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("AcadPlanner")
        }
    }
}

private struct DashboardCard: View
{
    let title: String
    let value: String
    
    var body: some View
    {
        HStack
        {
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    DashboardView()
}
