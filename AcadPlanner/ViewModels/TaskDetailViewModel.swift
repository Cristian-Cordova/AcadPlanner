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
    
    private let taskRepository: TaskRepository
    private let subjectRepository: SubjectRepository
    private let calendarRepository: CalendarRepository
    
    init
    (
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
        task.calendarSyncStatus != .added && task.calendarSyncStatus != .pending
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
    
    func addTaskToCalendar()
    {
        guard canAddToCalendar
        else
        {
            return
        }
        
        task.calendarSyncStatus = .pending
        task = taskRepository.saveTask(task)
        let eventId = calendarRepository.addTaskToCalendar(task)
        
        if let updatedTask = taskRepository.updateCalendarState(taskId: task.id, microsoftEventId: eventId,
                                                                status: .added
        )
        {
            task = updatedTask
            calendarEventMessage = "Task added to Microsoft Calendar"
        }
    }
}
