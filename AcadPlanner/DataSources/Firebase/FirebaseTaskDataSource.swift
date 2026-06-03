//
//  FirebaseTaskDataSource.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

final class FirebaseTaskDataSource
{
    private let collectionName = "academic_tasks"
    private let databaseProvider: () -> Firestore
    
    init(databaseProvider: @escaping () -> Firestore = { Firestore.firestore() })
    {
        self.databaseProvider = databaseProvider
    }
    
    func saveTask(
        _ task: AcademicTask,
        completion: @escaping (Result<AcademicTask, Error>) -> Void
    )
    {
        guard FirebaseApp.app() != nil
        else
        {
            completion(.failure(FirebaseTaskDataSourceError.firebaseNotConfigured))
            return
        }
        
        var syncedTask = task
        syncedTask.isSynced = true
        
        databaseProvider()
            .collection(collectionName)
            .document(task.id.uuidString)
            .setData(makeTaskData(from: syncedTask), merge: true)
        {
            error in
            if let error
            {
                completion(.failure(error))
                return
            }
            
            completion(.success(syncedTask))
        }
    }
    
    func deleteTask(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    {
        guard FirebaseApp.app() != nil
        else
        {
            completion(.failure(FirebaseTaskDataSourceError.firebaseNotConfigured))
            return
        }
        
        databaseProvider()
            .collection(collectionName)
            .document(id.uuidString)
            .delete
        {
            error in
            if let error
            {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    private func makeTaskData(from task: AcademicTask) -> [String: Any]
    {
        [
            "id": task.id.uuidString,
            "subjectId": task.subjectId.uuidString,
            "title": task.title,
            "description": task.description,
            "dueDate": Timestamp(date: task.dueDate),
            "priority": task.priority.rawValue,
            "status": task.status.rawValue,
            "type": task.type.rawValue,
            "microsoftEventId": task.microsoftEventId ?? NSNull(),
            "isAddedToCalendar": task.isAddedToCalendar,
            "calendarSyncStatus": task.calendarSyncStatus.rawValue,
            "createdAt": Timestamp(date: task.createdAt),
            "updatedAt": Timestamp(date: task.updatedAt),
            "isSynced": task.isSynced
        ]
    }
}

private enum FirebaseTaskDataSourceError: LocalizedError
{
    case firebaseNotConfigured
    
    var errorDescription: String?
    {
        switch self
        {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        }
    }
}
