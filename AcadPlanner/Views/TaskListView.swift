//
//  TaskListView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//
import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var isShowingTaskForm = false

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
                        isShowingTaskForm = true
                    }
                    label:
                    {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(isPresented: $isShowingTaskForm, onDismiss:
                    {
                viewModel.loadTasks()
            }) {
                TaskFormView(taskRepository: taskRepository)
            }
        }
    }
}

#Preview {
    TaskListView()
}
