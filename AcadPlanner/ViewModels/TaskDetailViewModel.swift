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
        // Bug 3 (parcial): también bloqueamos mientras se está procesando
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

    // Bug 2: renombrado a addToCalendar() para coincidir con la llamada en TaskDetailView
    // Bug 3: ahora usa Task { try await } para llamar correctamente al método async throws
    func addToCalendar()
    {
        // Bug 1 fix: task es @Published private(set) var — se puede mutar directamente en el ViewModel
        // No se necesita `guard var task` porque task ya es mutable aquí dentro
        guard canAddToCalendar else { return }

        isAddingToCalendar = true
        // Bug 4 fix: marcamos .pending mientras se procesa (en vez del inexistente .synced)
        task.calendarSyncStatus = .pending
        calendarEventMessage = nil

        // Bug 3 fix: CalendarRepository.addTaskToCalendar es async throws
        Task { @MainActor in
            do
            {
                let eventId = try await calendarRepository.addTaskToCalendar(task)

                // Bug 1 fix: mutamos self.task directamente (es var @Published)
                task.microsoftEventId = eventId
                task.isAddedToCalendar = true
                // Bug 4 fix: .added en lugar del inexistente .synced
                task.calendarSyncStatus = .added
                task.updatedAt = Date()

                // Bug 5 fix: saveTask(_:) en lugar del inexistente updateTask(_:)
                let saved = taskRepository.saveTask(task)
                task = saved

                calendarEventMessage = "Added to Google Calendar successfully."
            }
            catch
            {
                task.calendarSyncStatus = .failed
                calendarEventMessage = "Could not add to calendar: \(error.localizedDescription)"
            }

            isAddingToCalendar = false
        }
    }
}
