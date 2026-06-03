//
//  CalendarRepository.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

import Foundation

final class CalendarRepository
{
    func addTaskToCalendar(_ task: AcademicTask) -> String
    {
        "mock-microsoft-event-\(task.id.uuidString)"
    }
}
