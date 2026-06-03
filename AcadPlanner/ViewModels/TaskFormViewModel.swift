//
//  TaskFormViewModel.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import Combine

final class TaskFormViewModel: ObservableObject
{
    @Published var title: String
    @Published var description: String
    @Published var dueDate: Date
    @Published var priority: TaskPriority
    @Published var status: TaskStatus
    @Published var type: TaskType
    @Published var subjectId: UUID?
    @Published private(set) var validationMessage: String?

    private let task: AcademicTask?
    private let taskRepository: TaskRepository

    init
    (
        task: AcademicTask? = nil,
        taskRepository: TaskRepository = TaskRepository()
    )
    {
        self.task = task
        self.taskRepository = taskRepository
        self.title = task?.title ?? ""
        self.description = task?.description ?? ""
        self.dueDate = task?.dueDate ?? Date()
        self.priority = task?.priority ?? .medium
        self.status = task?.status ?? .pending
        self.type = task?.type ?? .task
        self.subjectId = task?.subjectId
    }

    var isEditing: Bool
    {
        task != nil
    }

    @discardableResult
    func saveTask() -> AcademicTask?
    {
        guard let subjectId else
        {
            validationMessage = "Select a subject before saving the task."
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else
        {
            validationMessage = "Enter a task title before saving."
            return nil
        }

        let taskToSave = AcademicTask(
            id: task?.id ?? UUID(),
            subjectId: subjectId,
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate,
            priority: priority,
            status: status,
            type: type,
            microsoftEventId: task?.microsoftEventId,
            isAddedToCalendar: task?.isAddedToCalendar ?? false,
            calendarSyncStatus: task?.calendarSyncStatus ?? .notAdded,
            createdAt: task?.createdAt ?? Date(),
            updatedAt: Date(),
            isSynced: false
        )

        validationMessage = nil
        return taskRepository.saveTask(taskToSave)
    }
}
