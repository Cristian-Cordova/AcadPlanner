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
    
    func subject( for subjectId: UUID) -> String
    {
        subjectRepository.fetchSubject(id: subjectId)?.name ?? "Unkown Subject"
    }
}
