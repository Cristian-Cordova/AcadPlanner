//
//  TaskPrority.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable, Identifiable
{
    case low
    case medium
    case high
    case urgent
    
    var id: String {rawValue}
    
    var displayName: String
    {
        switch self
        {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
}
