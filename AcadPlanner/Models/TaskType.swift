//
//  TaskType.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

enum TaskType: String, Codable, CaseIterable, Identifiable
{
    case task
    case project
    case exam
    case practice
    case reading
    case presentation
    
    var id: String {rawValue}
    
    var displayName: String
    {
        switch self
        {
        case .task:
            return "Task"
        case .project:
            return "Project"
        case .exam:
            return "Exam"
        case .practice:
            return "Practice"
        case .reading:
            return "Reading"
        case .presentation:
            return "Presentation"
        }
    }
}
