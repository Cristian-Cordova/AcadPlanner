//
//  TaskDetailView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel

    init(task: AcademicTask, taskRepository: TaskRepository = TaskRepository()) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(
            task: task,
            taskRepository: taskRepository
        ))
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

            Section("Subject") {
                LabeledContent("Name", value: viewModel.subjectName)
                LabeledContent("Professor", value: viewModel.professorName)
            }

            Section("Description") {
                Text(viewModel.task.description.isEmpty ? "No description provided." : viewModel.task.description)
                    .foregroundStyle(viewModel.task.description.isEmpty ? .secondary : .primary)
            }

            Section("Google Calendar") {
                LabeledContent("Calendar Status", value: viewModel.calendarStatusText)

                Button {
                    viewModel.addToCalendar()
                } label: {
                    HStack {
                        Text("Add to Google Calendar")
                        Spacer()
                        if viewModel.isAddingToCalendar {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(!viewModel.canAddToCalendar)

                if let message = viewModel.calendarEventMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let calendarEventLink = viewModel.calendarEventLink {
                    Link("Open in Google Calendar", destination: calendarEventLink)
                }
            }
        }
        .navigationTitle("Task Detail")
        .onAppear {
            viewModel.reloadTask()
        }
    }
}

#Preview {
    TaskDetailView(
        task: AcademicTask(
            subjectId: UUID(),
            title: "Prepare iOS project presentation",
            description: "Review MVVM structure and explain the Google Calendar integration.",
            dueDate: Date(),
            priority: .high,
            status: .pending,
            type: .project
        )
    )
}
