//
//  SQLiteTaskDataSource.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import SQLite3

final class SQLiteTaskDataSource
{
    private let databaseManager: DatabaseManager
    private let dateFormatter = ISO8601DateFormatter()
    
    init(databaseManager: DatabaseManager = .shared)
    {
        self.databaseManager = databaseManager
    }
    
    func fetchTasks() -> [AcademicTask]
    {
        let query = """
        SELECT id, subject_id, title, description, due_date, priority, status, type,
               microsoft_event_id, is_added_to_calendar, calendar_sync_status,
               created_at, updated_at, is_synced
        FROM academic_tasks
        ORDER BY due_date ASC;
        """
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return []
        }
        
        var tasks: [AcademicTask] = []
        
        while sqlite3_step(statement) == SQLITE_ROW
        {
            if let task = makeTask(from: statement)
            {
                tasks.append(task)
            }
        }
        
        sqlite3_finalize(statement)
        return tasks
    }
    
    func fetchTask(id: UUID) -> AcademicTask?
    {
        let query = """
        SELECT id, subject_id, title, description, due_date, priority, status, type,
               microsoft_event_id, is_added_to_calendar, calendar_sync_status,
               created_at, updated_at, is_synced
        FROM academic_tasks
        WHERE id = ?;
        """
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return nil
        }
        
        bindText(id.uuidString, to: statement, at: 1)
        
        let task = sqlite3_step(statement) == SQLITE_ROW
        ? makeTask(from: statement)
        : nil
        
        sqlite3_finalize(statement)
        return task
    }
    
    func fetchTasks(for subjectId: UUID) -> [AcademicTask]
    {
        let query = """
        SELECT id, subject_id, title, description, due_date, priority, status, type,
               microsoft_event_id, is_added_to_calendar, calendar_sync_status,
               created_at, updated_at, is_synced
        FROM academic_tasks
        WHERE subject_id = ?
        ORDER BY due_date ASC;
        """
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return []
        }
        
        bindText(subjectId.uuidString, to: statement, at: 1)
        
        var tasks: [AcademicTask] = []
        
        while sqlite3_step(statement) == SQLITE_ROW
        {
            if let task = makeTask(from: statement)
            {
                tasks.append(task)
            }
        }
        
        sqlite3_finalize(statement)
        return tasks
    }
    
    @discardableResult
    func saveTask(_ task: AcademicTask) -> AcademicTask
    {
        if fetchTask(id: task.id) == nil
        {
            insertTask(task)
        }
        else
        {
            updateTask(task)
        }
        
        return task
    }
    
    func deleteTask(id: UUID)
    {
        let query = "DELETE FROM academic_tasks WHERE id = ?;"
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return
        }
        
        bindText(id.uuidString, to: statement, at: 1)
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }
    
    private func insertTask(_ task: AcademicTask)
    {
        let query = """
        INSERT INTO academic_tasks (
            id, subject_id, title, description, due_date, priority, status, type,
            microsoft_event_id, is_added_to_calendar, calendar_sync_status,
            created_at, updated_at, is_synced
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return
        }
        
        bindTask(task, to: statement)
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }
    
    private func updateTask(_ task: AcademicTask)
    {
        let query = """
        UPDATE academic_tasks
        SET subject_id = ?,
            title = ?,
            description = ?,
            due_date = ?,
            priority = ?,
            status = ?,
            type = ?,
            microsoft_event_id = ?,
            is_added_to_calendar = ?,
            calendar_sync_status = ?,
            created_at = ?,
            updated_at = ?,
            is_synced = ?
        WHERE id = ?;
        """
        
        guard let statement = databaseManager.prepareStatement(query)
        else
        {
            return
        }
        
        bindText(task.subjectId.uuidString, to: statement, at: 1)
        bindText(task.title, to: statement, at: 2)
        bindText(task.description, to: statement, at: 3)
        bindText(dateFormatter.string(from: task.dueDate), to: statement, at: 4)
        bindText(task.priority.rawValue, to: statement, at: 5)
        bindText(task.status.rawValue, to: statement, at: 6)
        bindText(task.type.rawValue, to: statement, at: 7)
        bindOptionalText(task.microsoftEventId, to: statement, at: 8)
        sqlite3_bind_int(statement, 9, task.isAddedToCalendar ? 1 : 0)
        bindText(task.calendarSyncStatus.rawValue, to: statement, at: 10)
        bindText(dateFormatter.string(from: task.createdAt), to: statement, at: 11)
        bindText(dateFormatter.string(from: task.updatedAt), to: statement, at: 12)
        sqlite3_bind_int(statement, 13, task.isSynced ? 1 : 0)
        bindText(task.id.uuidString, to: statement, at: 14)
        
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }
    
    private func bindTask(_ task: AcademicTask, to statement: OpaquePointer?)
    {
        bindText(task.id.uuidString, to: statement, at: 1)
        bindText(task.subjectId.uuidString, to: statement, at: 2)
        bindText(task.title, to: statement, at: 3)
        bindText(task.description, to: statement, at: 4)
        bindText(dateFormatter.string(from: task.dueDate), to: statement, at: 5)
        bindText(task.priority.rawValue, to: statement, at: 6)
        bindText(task.status.rawValue, to: statement, at: 7)
        bindText(task.type.rawValue, to: statement, at: 8)
        bindOptionalText(task.microsoftEventId, to: statement, at: 9)
        sqlite3_bind_int(statement, 10, task.isAddedToCalendar ? 1 : 0)
        bindText(task.calendarSyncStatus.rawValue, to: statement, at: 11)
        bindText(dateFormatter.string(from: task.createdAt), to: statement, at: 12)
        bindText(dateFormatter.string(from: task.updatedAt), to: statement, at: 13)
        sqlite3_bind_int(statement, 14, task.isSynced ? 1 : 0)
    }
    
    private func makeTask(from statement: OpaquePointer?) -> AcademicTask?
    {
        guard
            let idText = sqlite3_column_text(statement, 0),
            let subjectIdText = sqlite3_column_text(statement, 1),
            let titleText = sqlite3_column_text(statement, 2),
            let descriptionText = sqlite3_column_text(statement, 3),
            let dueDateText = sqlite3_column_text(statement, 4),
            let priorityText = sqlite3_column_text(statement, 5),
            let statusText = sqlite3_column_text(statement, 6),
            let typeText = sqlite3_column_text(statement, 7),
            let calendarSyncStatusText = sqlite3_column_text(statement, 10),
            let createdAtText = sqlite3_column_text(statement, 11),
            let updatedAtText = sqlite3_column_text(statement, 12),
            let id = UUID(uuidString: String(cString: idText)),
            let subjectId = UUID(uuidString: String(cString: subjectIdText))
        else
        {
            return nil
        }
        
        let dueDateString = String(cString: dueDateText)
        let priorityString = String(cString: priorityText)
        let statusString = String(cString: statusText)
        let typeString = String(cString: typeText)
        let calendarSyncStatusString = String(cString: calendarSyncStatusText)
        let createdAtString = String(cString: createdAtText)
        let updatedAtString = String(cString: updatedAtText)
        let microsoftEventId = sqlite3_column_text(statement, 8).map
        {
            String(cString: $0)
        }
        
        return AcademicTask(
            id: id,
            subjectId: subjectId,
            title: String(cString: titleText),
            description: String(cString: descriptionText),
            dueDate: dateFormatter.date(from: dueDateString) ?? Date(),
            priority: TaskPriority(rawValue: priorityString) ?? .medium,
            status: TaskStatus(rawValue: statusString) ?? .pending,
            type: TaskType(rawValue: typeString) ?? .task,
            microsoftEventId: microsoftEventId,
            isAddedToCalendar: sqlite3_column_int(statement, 9) == 1,
            calendarSyncStatus: CalendarSyncStatus(rawValue: calendarSyncStatusString) ?? .notAdded,
            createdAt: dateFormatter.date(from: createdAtString) ?? Date(),
            updatedAt: dateFormatter.date(from: updatedAtString) ?? Date(),
            isSynced: sqlite3_column_int(statement, 13) == 1
        )
    }
    
    private func bindText(_ value: String, to statement: OpaquePointer?, at index: Int32)
    {
        let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, index, value, -1, sqliteTransient)
    }
    
    private func bindOptionalText(_ value: String?, to statement: OpaquePointer?, at index: Int32)
    {
        guard let value
        else
        {
            sqlite3_bind_null(statement, index)
            return
        }
        
        bindText(value, to: statement, at: index)
    }
}
