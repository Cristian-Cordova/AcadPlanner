//
//  CalendarSyncStatus.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

enum CalendarSyncStatus: String, Codable, CaseIterable, Identifiable
{
    case notAdded
    case pending
    case added
    case failed
    
    var id: String {rawValue}
    
    var displayName: String
    {
        switch self
        {
        case .notAdded:
            return "Not Added"
        case .pending:
            return "Pending"
            case .added:
            return "Added"
        case .failed:
            return "Failed"
        }
    }
}
