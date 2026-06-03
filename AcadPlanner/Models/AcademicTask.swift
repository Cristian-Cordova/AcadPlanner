//
//  AcademicTask.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

struct AcademicTask: Identifiable, Codable, Equatable
{
    let id: UUID
    var subjectId: UUID
    var title: String
    var description: String
    var dueDate: Date
    var priority: TaskPriority
    var status: TaskStatus
    var type: TaskType
    
    var microsoftEventId: String?
    var isAddedToCalendar: Bool
    var calendarySyncStatus: CalendarSyncStatus
    
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool
    
    init(
        id: UUID = UUID(),
        subjectId: UUID,
        title: String,
        description: String = "",
        dueDate: Date,
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        type: TaskType = .task,
        microsoftEventId: String? = nil,
        isAddedToCalendar: Bool = false,
        calendarySyncStatus: CalendarSyncStatus = .notAdded,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSynced: Bool = false
    )
    {
        self.id = id
        self.subjectId = subjectId
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.type = type
        self.microsoftEventId = microsoftEventId
        self.isAddedToCalendar = isAddedToCalendar
        self.isAddedToCalendar = isAddedToCalendar
        self.calendarySyncStatus = calendarySyncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
    }
}
