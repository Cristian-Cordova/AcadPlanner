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

    func addTaskToCalendar(_ task: AcademicTask) async throws -> CalendarEventResult {
        let accessToken = try await authService.signIn()

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: task.dueDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate.addingTimeInterval(86400)

        return try await calendarService.createEvent(
            accessToken: accessToken,
            title: task.title,
            notes: task.description,
            startDate: startDate,
            endDate: endDate
        )
    }
}
