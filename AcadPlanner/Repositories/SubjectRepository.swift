//
//  SubjectRepository.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

enum MockRepositoryData
{
    static let mathematicsSubjectId = UUID(uuidString: "1F2443C5-14F8-4D2F-9F8A-071B54F9E001")!
    static let iosDevelopmentSubjectId = UUID(uuidString: "1F2443C5-14F8-4D2F-9F8A-071B54F9E002")!
    static let databasesSubjectId = UUID(uuidString: "1F2443C5-14F8-4D2F-9F8A-071B54F9E003")!

    static let subjects: [Subject] = [
        Subject(id: mathematicsSubjectId, name: "Mathematics", professor: "Dr. Hernandez", colorHex: "#3B82F6", isSynced: true),
        Subject(id: iosDevelopmentSubjectId, name: "iOS Development", professor: "Prof. Rivera", colorHex: "#10B981", isSynced: true),
        Subject(id: databasesSubjectId, name: "Databases", professor: "Prof. Molina", colorHex: "#8B5CF6", isSynced: false)
    ]
}

final class SubjectRepository
{
    private let localDataSource: SQLiteSubjectDataSource
    private let remoteDataSource: FirebaseSubjectDataSource
    // Bug 10 fix: necesitamos acceso a los DataSources de tareas para eliminarlas en cascada
    private let localTaskDataSource: SQLiteTaskDataSource
    private let remoteTaskDataSource: FirebaseTaskDataSource

    private let seedInitialData: Bool
    private let initialDataSeedKey = "didSeedInitialSubjects"

    init(
        localDataSource: SQLiteSubjectDataSource = SQLiteSubjectDataSource(),
        remoteDataSource: FirebaseSubjectDataSource = FirebaseSubjectDataSource(),
        localTaskDataSource: SQLiteTaskDataSource = SQLiteTaskDataSource(),
        remoteTaskDataSource: FirebaseTaskDataSource = FirebaseTaskDataSource(),
        seedInitialData: Bool = true
    )
    {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.localTaskDataSource = localTaskDataSource
        self.remoteTaskDataSource = remoteTaskDataSource
        self.seedInitialData = seedInitialData
        seedInitialSubjectsIfNeeded()
    }

    func fetchSubjects() -> [Subject]
    {
        localDataSource.fetchSubjects()
    }

    func fetchSubject(id: UUID) -> Subject?
    {
        localDataSource.fetchSubject(id: id)
    }

    @discardableResult
    func saveSubject(_ subject: Subject) -> Subject
    {
        var subjectToSave = subject
        subjectToSave.updatedAt = Date()
        subjectToSave.isSynced = false

        let savedSubject = localDataSource.saveSubject(subjectToSave)
        syncSubjectWithFirebase(savedSubject)

        return savedSubject
    }

    func deleteSubject(id: UUID)
    {
        // Bug 10 fix: primero eliminamos las tareas asociadas localmente
        let tasksToDelete = localTaskDataSource.fetchTasks(for: id)
        tasksToDelete.forEach { task in
            localTaskDataSource.deleteTask(id: task.id)
            // Bug 10 fix: también se eliminan de Firebase
            remoteTaskDataSource.deleteTask(id: task.id) { _ in }
        }

        // Luego eliminamos la materia
        localDataSource.deleteSubject(id: id)
        deleteSubjectFromFirebase(id: id)
    }

    private func seedInitialSubjectsIfNeeded()
    {
        guard seedInitialData,
              !UserDefaults.standard.bool(forKey: initialDataSeedKey),
              localDataSource.fetchSubjects().isEmpty
        else { return }

        MockRepositoryData.subjects.forEach { localDataSource.saveSubject($0) }
        UserDefaults.standard.set(true, forKey: initialDataSeedKey)
    }

    private func syncSubjectWithFirebase(_ subject: Subject)
    {
        remoteDataSource.saveSubject(subject) { [weak self] result in
            guard let self else { return }

            switch result
            {
            case .success(let syncedSubject):
                DispatchQueue.main.async {
                    self.localDataSource.saveSubject(syncedSubject)
                }
            case .failure:
                break
            }
        }
    }

    private func deleteSubjectFromFirebase(id: UUID)
    {
        remoteDataSource.deleteSubject(id: id) { _ in }
    }
}
