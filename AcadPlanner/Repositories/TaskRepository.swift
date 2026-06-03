//
//  TaskRepository.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

final class TaskRepository
{
    private let localDataSource: SQLiteTaskDataSource
    private let remoteDataSource: FirebaseTaskDataSource
    private let seedInitialData: Bool
    private let initialDataSeedKey = "didSeedInitialTasks"

    init(
        localDataSource: SQLiteTaskDataSource = SQLiteTaskDataSource(),
        remoteDataSource: FirebaseTaskDataSource = FirebaseTaskDataSource(),
        seedInitialData: Bool = true
    )
    {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.seedInitialData = seedInitialData
        seedInitialTasksIfNeeded()
    }

    func fetchTasks() -> [AcademicTask]
    {
        localDataSource.fetchTasks()
    }

    func fetchTask(id: UUID) -> AcademicTask?
    {
        localDataSource.fetchTask(id: id)
    }

    func fetchTasks(for subjectId: UUID) -> [AcademicTask]
    {
        localDataSource.fetchTasks(for: subjectId)
    }

    func fetchTasks(status: TaskStatus) -> [AcademicTask]
    {
        fetchTasks().filter { $0.status == status }
    }

    func fetchUpcomingTasks(limit: Int = 5) -> [AcademicTask]
    {
        fetchTasks()
            .filter { $0.status != .completed && $0.dueDate >= Date() }
            .prefix(limit)
            .map { $0 }
    }

    @discardableResult
    func saveTask(_ task: AcademicTask) -> AcademicTask
    {
        var taskToSave = task
        taskToSave.updatedAt = Date()
        taskToSave.isSynced = false

        let savedTask = localDataSource.saveTask(taskToSave)
        syncTaskWithFirebase(savedTask)
        
        return savedTask
    }

    func deleteTask(id: UUID)
    {
        localDataSource.deleteTask(id: id)
        deleteTaskFromFirebase(id: id)
    }

    @discardableResult
    func updateCalendarState(taskId: UUID, microsoftEventId: String, status: CalendarSyncStatus = .added) -> AcademicTask?
    {
        guard var task = fetchTask(id: taskId)
        else
        {
            return nil
        }

        task.microsoftEventId = microsoftEventId
        task.isAddedToCalendar = status == .added
        task.calendarSyncStatus = status
        task.updatedAt = Date()
        task.isSynced = false

        return saveTask(task)
    }

    private func seedInitialTasksIfNeeded()
    {
        guard seedInitialData,
              !UserDefaults.standard.bool(forKey: initialDataSeedKey),
              localDataSource.fetchTasks().isEmpty
        else
        {
            return
        }
        
        Self.makeMockTasks().forEach
        {
            localDataSource.saveTask($0)
        }
        
        UserDefaults.standard.set(true, forKey: initialDataSeedKey)
    }

    private static func makeMockTasks() -> [AcademicTask]
    {
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
    
    private func syncTaskWithFirebase(_ task: AcademicTask)
    {
        remoteDataSource.saveTask(task)
        {
            [weak self] result in
            guard let self
            else
            {
                return
            }
            
            switch result
            {
            case .success(let syncedTask):
                DispatchQueue.main.async
                {
                    self.localDataSource.saveTask(syncedTask)
                }
            case .failure:
                break
            }
        }
    }
    
    private func deleteTaskFromFirebase(id: UUID)
    {
        remoteDataSource.deleteTask(id: id)
        {
            _ in
        }
    }
}
