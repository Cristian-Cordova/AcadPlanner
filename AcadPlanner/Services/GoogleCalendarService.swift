//
//  GoogleCalendarService.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 03/06/26.
//

import Foundation

final class GoogleCalendarService {
    private let calendarEventsURL = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!

    func createEvent(
        accessToken: String,
        title: String,
        notes: String?,
        startDate: Date,
        endDate: Date
    ) async throws -> CalendarEventResult {
        let requestBody = GoogleCalendarEventRequest(
            summary: title,
            description: notes,
            start: GoogleCalendarEventDate(date: startDate.googleCalendarDateString),
            end: GoogleCalendarEventDate(date: endDate.googleCalendarDateString)
        )

        var request = URLRequest(url: calendarEventsURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw GoogleCalendarError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let decodedResponse = try JSONDecoder().decode(GoogleCalendarEventResponse.self, from: data)
        return CalendarEventResult(
            id: decodedResponse.id,
            htmlLink: decodedResponse.htmlLink.flatMap(URL.init(string:))
        )
    }
}

struct CalendarEventResult {
    let id: String
    let htmlLink: URL?
}

private struct GoogleCalendarEventRequest: Encodable {
    let summary: String
    let description: String?
    let start: GoogleCalendarEventDate
    let end: GoogleCalendarEventDate
}

private struct GoogleCalendarEventDate: Encodable {
    let date: String
}

private struct GoogleCalendarEventResponse: Decodable {
    let id: String
    let htmlLink: String?
}

enum GoogleCalendarError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Google Calendar returned an invalid response."
        case .requestFailed(let statusCode):
            return "Google Calendar request failed with status code \(statusCode)."
        }
    }
}

private extension Date {
    var googleCalendarDateString: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
