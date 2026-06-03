//
//  TaskFormView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 03/06/26.
//

import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: TaskFormViewModel
    @StateObject private var subjectViewModel = SubjectViewModel()

    init(task: AcademicTask? = nil, taskRepository: TaskRepository = TaskRepository())
    {
        _viewModel = StateObject(
            wrappedValue: TaskFormViewModel(
                task: task,
                taskRepository: taskRepository
            )
        )
    }
    
    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section("Task Information")
                {
                    TextField("Title", text: $viewModel.title)

                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...5)

                    DatePicker(
                        "Due Date",
                        selection: $viewModel.dueDate,
                        displayedComponents: .date
                    )
                }

                Section("Academic Details")
                {
                    Picker("Subject", selection: $viewModel.subjectId)
                    {
                        Text("Select a subject")
                            .tag(UUID?.none)

                        ForEach(subjectViewModel.subjects)
                        {
                            subject in Text(subject.name)
                                .tag(Optional(subject.id))
                        }
                    }

                    Picker("Priority", selection: $viewModel.priority)
                    {
                        ForEach(TaskPriority.allCases)
                        {
                            priority in Text(priority.displayName)
                                .tag(priority)
                        }
                    }

                    Picker("Status", selection: $viewModel.status)
                    {
                        ForEach(TaskStatus.allCases)
                        {
                            status in Text(status.displayName)
                                .tag(status)
                        }
                    }

                    Picker("Type", selection: $viewModel.type)
                    {
                        ForEach(TaskType.allCases)
                        {
                            type in Text(type.displayName)
                                .tag(type)
                        }
                    }
                }

                if let validationMessage = viewModel.validationMessage
                {
                    Section
                    {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Task" : "New Task")
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction)
                {
                    Button("Save")
                    {
                        if viewModel.saveTask() != nil
                        {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TaskFormView()
}
