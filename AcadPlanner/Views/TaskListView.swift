//
//  TaskListView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//
import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tasks) { task in
                    NavigationLink {
                        TaskDetailView(task: task)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.headline)

                            Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Text(task.status.displayName)
                                Text(task.priority.displayName)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { viewModel.tasks[$0].id }
                        .forEach { viewModel.deleteTask(id: $0) }
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    TaskListView()
}
