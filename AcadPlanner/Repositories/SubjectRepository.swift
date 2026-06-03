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
    
    final class SubjectRepository
    {
        private var subjects: [Subject]
        
        init(subjects: [Subject] = MockRepositoryData.subjects)
        {
            self.subjects = subjects
        }
        
        func fetchSubjects() -> [Subject]
        {
            subjects.sorted
            { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
        
        func fetchSubject(id: UUID) -> Subject?
        {
            subjects.first
            { $0.id == id }
        }
        
        @discardableResult
        func saveSubject(_ subject: Subject) -> Subject
        {
            var subjectToSave = subject
            subjectToSave.updatedAt = Date()
            
            if let index = subjects.firstIndex(where:{ $0.id == subject.id })
            {
                subjects[index] = subjectToSave
            } else
            {
                subjects.append(subjectToSave)
            }
            
            return subjectToSave
        }
        
        func deleteSubject(id: UUID)
        {
            subjects.removeAll { $0.id == id }
        }
    }
}
