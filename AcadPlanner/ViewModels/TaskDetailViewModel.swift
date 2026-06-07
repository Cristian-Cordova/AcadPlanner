//
//  TaskDetailViewModel.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import Combine

final class TaskDetailViewModel: ObservableObject
{
    @Published private(set) var task: AcademicTask
    @Published private(set) var subject: Subject?
    @Published private(set) var calendarEventMessage: String?
    @Published private(set) var calendarEventLink: URL?
    @Published private(set) var isAddingToCalendar: Bool = false

    private let taskRepository: TaskRepository
    private let subjectRepository: SubjectRepository
    private let calendarRepository: CalendarRepository

    init(
        task: AcademicTask,
        taskRepository: TaskRepository = TaskRepository(),
        subjectRepository: SubjectRepository = SubjectRepository(),
        calendarRepository: CalendarRepository = CalendarRepository()
    )
    {
        self.task = task
        self.taskRepository = taskRepository
        self.subjectRepository = subjectRepository
        self.calendarRepository = calendarRepository
        loadSubject()
    }

    var calendarStatusText: String
    {
        task.calendarSyncStatus.displayName
    }

    var canAddToCalendar: Bool
    {
        !isAddingToCalendar &&
        task.calendarSyncStatus != .added &&
        task.calendarSyncStatus != .pending
    }

    var subjectName: String
    {
        subject?.name ?? "Unknown Subject"
    }

    var professorName: String
    {
        guard let professor = subject?.professor, !professor.isEmpty
        else
        {
            return "No professor assigned."
        }
        return professor
    }

    func loadSubject()
    {
        subject = subjectRepository.fetchSubject(id: task.subjectId)
    }

    func addToCalendar()
    {

        guard canAddToCalendar else { return }

        isAddingToCalendar = true
        task.calendarSyncStatus = .pending
        calendarEventMessage = nil
        calendarEventLink = nil

        Task { @MainActor in
            do
            {
                let calendarEvent = try await calendarRepository.addTaskToCalendar(task)

                task.microsoftEventId = calendarEvent.id
                task.isAddedToCalendar = true
                task.calendarSyncStatus = .added
                task.updatedAt = Date()

                let saved = taskRepository.saveTask(task)
                task = saved

                calendarEventLink = calendarEvent.htmlLink
                calendarEventMessage = "Added to Google Calendar successfully."
            }
            catch
            {
                task.calendarSyncStatus = .failed
                _ = taskRepository.saveTask(task)
                calendarEventMessage = "Could not add to calendar: \(error.localizedDescription)"
            }

            isAddingToCalendar = false
        }
    }
    
    func reloadTask() {
        if let updated = taskRepository.fetchTask(id: task.id) {
            task = updated
        }
        loadSubject()
    }
}
