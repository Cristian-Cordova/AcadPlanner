//
//  TaskListView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//
import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var formDestination: TaskFormDestination?

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository())
    {
        self.taskRepository = taskRepository
        _viewModel = StateObject(
            wrappedValue: TaskListViewModel(taskRepository: taskRepository)
        )
    }

    var body: some View
    {
        NavigationStack
        {
            List
            {
                ForEach(viewModel.tasks)
                {
                    task in NavigationLink
                    {
                        TaskDetailView(task: task)
                    }
                    label:
                    {
                        VStack(alignment: .leading, spacing: 6)
                        {
                            Text(task.title)
                                .font(.headline)

                            Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack
                            {
                                Text(task.status.displayName)
                                Text(task.priority.displayName)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false)
                    {
                        Button(role: .destructive)
                        {
                            viewModel.deleteTask(id: task.id)
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false)
                    {
                        Button("Edit")
                        {
                            formDestination = .edit(task)
                        }
                        .tint(.blue)
                    }
                }
                .onDelete
                {
                    indexSet in indexSet
                        .map
                    { viewModel.tasks[$0].id }
                        .forEach
                    { viewModel.deleteTask(id: $0) }
                }
            }
            .navigationTitle("Tasks")
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing)
                {
                    Button
                    {
                        formDestination = .create
                    }
                    label:
                    {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(item: $formDestination, onDismiss:
                    {
                viewModel.loadTasks()
            }) {
                destination in
                switch destination
                {
                case .create:
                    TaskFormView(taskRepository: taskRepository)
                case .edit(let task):
                    TaskFormView(task: task, taskRepository: taskRepository)
                }
            }
        }
    }
}

private enum TaskFormDestination: Identifiable
{
    case create
    case edit(AcademicTask)
    
    var id: String
    {
        switch self
        {
        case .create:
            return "create"
        case .edit(let task):
            return task.id.uuidString
        }
    }
}

#Preview {
    TaskListView()
}
