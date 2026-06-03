//
//  TaskStatus.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

enum TaskStatus: String, Codable, CaseIterable, Identifiable
{
    case pending
    case inProgress
    case completed
    
    var id: String {rawValue}
    
    var displayName: String
    {
        switch self
        {
        case .pending:
            return "Pending"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        }
    }
}

