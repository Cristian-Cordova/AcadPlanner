//
//  FirebaseSubjectDataSource.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

final class FirebaseSubjectDataSource
{
    private let collectionName = "subjects"
    private let databaseProvider: () -> Firestore
    
    init(databaseProvider: @escaping () -> Firestore = { Firestore.firestore() })
    {
        self.databaseProvider = databaseProvider
    }
    
    func saveSubject(
        _ subject: Subject,
        completion: @escaping (Result<Subject, Error>) -> Void
    )
    {
        guard FirebaseApp.app() != nil
        else
        {
            completion(.failure(FirebaseSubjectDataSourceError.firebaseNotConfigured))
            return
        }
        
        var syncedSubject = subject
        syncedSubject.isSynced = true
        
        databaseProvider()
            .collection(collectionName)
            .document(subject.id.uuidString)
            .setData(makeSubjectData(from: syncedSubject), merge: true)
        {
            error in
            if let error
            {
                completion(.failure(error))
                return
            }
            
            completion(.success(syncedSubject))
        }
    }
    
    func deleteSubject(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    {
        guard FirebaseApp.app() != nil
        else
        {
            completion(.failure(FirebaseSubjectDataSourceError.firebaseNotConfigured))
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
    
    private func makeSubjectData(from subject: Subject) -> [String: Any]
    {
        [
            "id": subject.id.uuidString,
            "name": subject.name,
            "professor": subject.professor,
            "colorHex": subject.colorHex,
            "createdAt": Timestamp(date: subject.createdAt),
            "updatedAt": Timestamp(date: subject.updatedAt),
            "isSynced": subject.isSynced
        ]
    }
}

private enum FirebaseSubjectDataSourceError: LocalizedError
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
