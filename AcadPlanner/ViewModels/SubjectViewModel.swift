//
//  SubjectViewModel.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import Combine

final class SubjectViewModel: ObservableObject
{
    @Published private(set) var subjects: [Subject] = []
    @Published private(set) var validationMessage: String?
    
    private let subjectRepository: SubjectRepository
    
    init(subjectRepository: SubjectRepository = SubjectRepository())
    {
        self.subjectRepository = subjectRepository
        loadSubjects()
    }
    
    func loadSubjects()
    {
        subjects = subjectRepository.fetchSubjects()
    }
    
    func subject(for subjectId: UUID) -> String
    {
        subjectRepository.fetchSubject(id: subjectId)?.name ?? "Unknown Subject"
    }
    
    @discardableResult
    func saveSubject(
        subject: Subject? = nil,
        name: String,
        professor: String,
        colorHex: String = "#3B82F6"
    ) -> Subject?
    {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProfessor = professor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColorHex = colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty
        else
        {
            validationMessage = "Enter a subject name before saving."
            return nil
        }
        
        let subjectToSave = Subject(
            id: subject?.id ?? UUID(),
            name: trimmedName,
            professor: trimmedProfessor,
            colorHex: trimmedColorHex.isEmpty ? "#3B82F6" : trimmedColorHex,
            createdAt: subject?.createdAt ?? Date(),
            updatedAt: Date(),
            isSynced: false
        )
        
        let savedSubject = subjectRepository.saveSubject(subjectToSave)
        validationMessage = nil
        loadSubjects()
        
        return savedSubject
    }
    
    func deleteSubject(id: UUID)
    {
        subjectRepository.deleteSubject(id: id)
        loadSubjects()
    }
}
