# MVP Scope — AcadPlanner

## Project Name

AcadPlanner

## General Description

AcadPlanner is an iOS application developed with SwiftUI to manage academic tasks by subject. The app allows users to register subjects, create tasks, classify them by status, priority, and type, view them from a dashboard, and track calendar integration state for selected tasks.

The project is designed as a solid academic MVP, using an architecture based on MVVM, repositories, local storage with SQLite, remote backup with Firebase, and a prepared external integration layer for Microsoft Calendar through Microsoft Graph.

## MVP Objective

To develop a functional application that allows students to organize their academic tasks, maintain local access to information through SQLite, back up data with Firebase, and prepare the app for Microsoft Calendar event creation through Microsoft Graph.

## Features Included in the MVP

The AcadPlanner MVP will include:

- Main dashboard.
- CRUD operations for subjects.
- CRUD operations for academic tasks.
- Task statuses:
  - pending
  - in progress
  - completed
- Priorities:
  - low
  - medium
  - high
  - urgent
- Task types:
  - task
  - project
  - exam
  - practice
  - reading
  - presentation
- SQLite as local storage.
- Firebase Firestore as remote backup.
- Microsoft Calendar integration state through `calendarSyncStatus`.
- Mock Microsoft Calendar event creation through `CalendarRepository`.
- Saving the generated `microsoftEventId` used by the current mock flow.
- Calendar synchronization status using `calendarSyncStatus`.
- Indicator to know whether a task has already been added to the calendar.

## Features Outside the MVP Scope

To keep the scope realistic, the MVP will not include:

- Google Calendar.
- Weather.
- Motivational quotes.
- Holidays.
- Full reading of the Microsoft Calendar.
- Bidirectional synchronization with Microsoft Calendar.
- Advanced editing of Outlook events from the app.
- Recurring events.
- User collaboration.
- User roles.
- Advanced notifications.
- Integration with other calendars.
- Real Microsoft Graph authentication until a Microsoft Entra ID app registration is available.

## Main Architecture Rule

The ViewModel must not communicate directly with external services.  
The ViewModel must communicate with repositories.

For the planned Microsoft Calendar integration, the official flow will be:

```text
TaskDetailView
↓
TaskDetailViewModel
↓
CalendarRepository
↓
MicrosoftAuthService
↓
MicrosoftCalendarService
↓
microsoftEventId
↓
TaskDetailViewModel
↓
TaskRepository
↓
SQLite + Firebase
```

`CalendarRepository` coordinates Microsoft authentication and event creation.  
`MicrosoftAuthService` and `MicrosoftCalendarService` are internal details of the services layer.

## Architectural Justification

This separation keeps presentation logic isolated from external integration logic. The `TaskDetailViewModel` does not need to know how Microsoft Graph works, how an access token is obtained, or how the HTTP request to create an event is built. Its responsibility is to manage the screen state and ask the repository to add the task to the calendar.

This makes AcadPlanner more maintainable, easier to test, and more scalable after the MVP.

## Microsoft Graph Integration Status

Microsoft Graph calendar integration is currently prepared at the architecture level but not fully activated. During development, the account used for Microsoft Entra ID could not create an app registration because it did not have access to a valid tenant or Microsoft 365 Developer sandbox.

The feature can be activated later when the following configuration is available:

- Microsoft Entra ID app registration.
- Application client ID.
- iOS/macOS redirect URI.
- Bundle ID: `com.cristiancordova.AcadPlanner`.
- Redirect URI: `msauth.com.cristiancordova.AcadPlanner://auth`.
- Microsoft Graph delegated permission: `Calendars.ReadWrite`.

No client secret should be embedded in the iOS app. The future implementation should use delegated user authentication through MSAL.
