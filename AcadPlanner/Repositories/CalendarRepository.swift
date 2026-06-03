//
//  CalendarRepository.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

final class CalendarRepository {
    private let authService: GoogleAuthService
    private let calendarService: GoogleCalendarService

    init(
        authService: GoogleAuthService = GoogleAuthService(),
        calendarService: GoogleCalendarService = GoogleCalendarService()
    ) {
        self.authService = authService
        self.calendarService = calendarService
    }

    func addTaskToCalendar(_ task: AcademicTask) async throws -> String {
        let accessToken = try await authService.signIn()

        return try await calendarService.createEvent(
            accessToken: accessToken,
            title: task.title,
            notes: task.description,
            startDate: task.dueDate,
            endDate: task.dueDate.addingTimeInterval(3600)
        )
    }
}
