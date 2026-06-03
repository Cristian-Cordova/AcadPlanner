//
//  TaskRepository.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

final class TaskRepository {
    private var tasks: [AcademicTask]

    init(tasks: [AcademicTask] = TaskRepository.makeMockTasks()) {
        self.tasks = tasks
    }

    func fetchTasks() -> [AcademicTask] {
        tasks.sorted { $0.dueDate < $1.dueDate }
    }

    func fetchTask(id: UUID) -> AcademicTask? {
        tasks.first { $0.id == id }
    }

    func fetchTasks(for subjectId: UUID) -> [AcademicTask] {
        fetchTasks().filter { $0.subjectId == subjectId }
    }

    func fetchTasks(status: TaskStatus) -> [AcademicTask] {
        fetchTasks().filter { $0.status == status }
    }

    func fetchUpcomingTasks(limit: Int = 5) -> [AcademicTask] {
        fetchTasks()
            .filter { $0.status != .completed }
            .prefix(limit)
            .map { $0 }
    }

    @discardableResult
    func saveTask(_ task: AcademicTask) -> AcademicTask {
        var taskToSave = task
        taskToSave.updatedAt = Date()

        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = taskToSave
        } else {
            tasks.append(taskToSave)
        }

        return taskToSave
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    @discardableResult
    func updateCalendarState(taskId: UUID, microsoftEventId: String, status: CalendarSyncStatus = .added) -> AcademicTask? {
        guard var task = fetchTask(id: taskId) else {
            return nil
        }

        task.microsoftEventId = microsoftEventId
        task.isAddedToCalendar = status == .added
        task.calendarSyncStatus = status
        task.updatedAt = Date()

        return saveTask(task)
    }

    private static func makeMockTasks() -> [AcademicTask] {
        [
            AcademicTask(
                subjectId: MockRepositoryData.iosDevelopmentSubjectId,
                title: "Build AcadPlanner MVP",
                description: "Create the first functional academic task planner structure.",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                priority: .urgent,
                status: .inProgress,
                type: .project
            ),
            AcademicTask(
                subjectId: MockRepositoryData.databasesSubjectId,
                title: "Review SQLite integration",
                description: "Prepare notes about local persistence and CRUD operations.",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                priority: .high,
                status: .pending,
                type: .reading,
                isSynced: true
            )
        ]
    }
}
