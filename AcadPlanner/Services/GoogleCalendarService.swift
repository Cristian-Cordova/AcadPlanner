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
    ) async throws -> String {
        let requestBody = GoogleCalendarEventRequest(
            summary: title,
            description: notes,
            start: GoogleCalendarEventDateTime(dateTime: startDate.rfc3339String),
            end: GoogleCalendarEventDateTime(dateTime: endDate.rfc3339String)
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
        return decodedResponse.id
    }
}

private struct GoogleCalendarEventRequest: Encodable {
    let summary: String
    let description: String?
    let start: GoogleCalendarEventDateTime
    let end: GoogleCalendarEventDateTime
}

private struct GoogleCalendarEventDateTime: Encodable {
    let dateTime: String
    let timeZone = TimeZone.current.identifier
}

private struct GoogleCalendarEventResponse: Decodable {
    let id: String
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
    var rfc3339String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}
