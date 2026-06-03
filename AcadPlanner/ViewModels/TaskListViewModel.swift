//
//  TaskListViewModel.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import Combine

final class TaskListViewModel: ObservableObject
{
    @Published private(set) var tasks: [AcademicTask] = []

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository())
    {
        self.taskRepository = taskRepository
        loadTasks()
    }

    func loadTasks()
    {
        tasks = taskRepository.fetchTasks()
    }

    func tasks(for status: TaskStatus) -> [AcademicTask]
    {
        tasks.filter { $0.status == status }
    }

    func tasks(for subjectId: UUID) -> [AcademicTask]
    {
        tasks.filter { $0.subjectId == subjectId }
    }

    func deleteTask(id: UUID)
    {
        taskRepository.deleteTask(id: id)
        loadTasks()
        NotificationCenter.default.post(name: .taskDataDidChange, object: nil)
    }
}
