//
//  TaskDetailView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel

    init(task: AcademicTask) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(task: task))
    }

    var body: some View {
        Form {
            Section("Task Information") {
                LabeledContent("Title", value: viewModel.task.title)
                LabeledContent("Type", value: viewModel.task.type.displayName)
                LabeledContent("Priority", value: viewModel.task.priority.displayName)
                LabeledContent("Status", value: viewModel.task.status.displayName)
                LabeledContent(
                    "Due Date",
                    value: viewModel.task.dueDate.formatted(date: .abbreviated, time: .omitted)
                )
            }

            Section("Description") {
                Text(viewModel.task.description.isEmpty ? "No description provided." : viewModel.task.description)
                    .foregroundStyle(viewModel.task.description.isEmpty ? .secondary : .primary)
            }

            Section("Microsoft Calendar") {
                LabeledContent("Calendar Status", value: viewModel.calendarStatusText)

                Button("Add to Microsoft Calendar") {
                    viewModel.addTaskToCalendar()
                }
                .disabled(!viewModel.canAddToCalendar)

                if let message = viewModel.calendarEventMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Task Detail")
    }
}

#Preview {
    TaskDetailView(
        task: AcademicTask(
            subjectId: UUID(),
            title: "Prepare iOS project presentation",
            description: "Review MVVM structure and explain the Microsoft Calendar integration.",
            dueDate: Date(),
            priority: .high,
            status: .pending,
            type: .project
        )
    )
}
