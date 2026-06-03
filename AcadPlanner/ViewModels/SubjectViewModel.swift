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
    func saveSubject(name: String, professor: String, colorHex: String = "#3B82F6") -> Subject?
    {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProfessor = professor.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty
        else
        {
            validationMessage = "Enter a subject name before saving."
            return nil
        }
        
        let subject = Subject(
            name: trimmedName,
            professor: trimmedProfessor,
            colorHex: colorHex,
            isSynced: false
        )
        
        let savedSubject = subjectRepository.saveSubject(subject)
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
