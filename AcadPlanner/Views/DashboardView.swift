//
//  DashboardView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//
import SwiftUI

extension Notification.Name {
    static let taskDataDidChange = Notification.Name("taskDataDidChange")
}

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View
    {
        NavigationStack
        {
            List
            {
                Section("Overview")
                {
                    DashboardCard(title: "Upcoming Tasks", value: "\(viewModel.upcomingTasks.count)")
                    DashboardCard(title: "Pending Tasks", value: "\(viewModel.pendingTaskCount)")
                    DashboardCard(title: "Completed Tasks", value: "\(viewModel.completedTaskCount)")
                    DashboardCard(title: "Added to Calendar", value: "\(viewModel.calendarTaskCount)")
                }

                Section("Next Deadlines")
                {
                    if viewModel.upcomingTasks.isEmpty
                    {
                        Text("No upcoming tasks.")
                            .foregroundStyle(.secondary)
                    }
                    else
                    {
                        ForEach(viewModel.upcomingTasks)
                        { task in
                            VStack(alignment: .leading, spacing: 4)
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
            }
            .navigationTitle("AcadPlanner")
            // Bug 9 fix: carga inicial con .task (equivalente a onAppear pero async-safe)
            .task { viewModel.loadDashboardData() }
            // Bug 9 fix: recarga cuando cualquier vista guarda o modifica datos
            .onReceive(NotificationCenter.default.publisher(for: .taskDataDidChange))
            { _ in
                viewModel.loadDashboardData()
            }
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
