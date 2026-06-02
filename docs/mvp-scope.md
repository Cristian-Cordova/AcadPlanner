# MVP Scope — AcadPlanner

## Project Name

AcadPlanner

## General Description

AcadPlanner is an iOS application developed with SwiftUI to manage academic tasks by subject. The app allows users to register subjects, create tasks, classify them by status, priority, and type, view them from a dashboard, and add selected tasks to Microsoft Calendar through Microsoft Graph.

The project is designed as a solid academic MVP, using an architecture based on MVVM, repositories, local storage with SQLite, remote backup/synchronization with Firebase, and external integration with Microsoft Calendar.

## MVP Objective

To develop a functional application that allows students to organize their academic tasks, maintain local access to information through SQLite, back up data with Firebase, and create Microsoft Calendar events from existing tasks.

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
- Firebase as remote backup/synchronization.
- Microsoft Graph only for creating events from existing tasks.
- Saving the `microsoftEventId` returned by Microsoft Calendar.
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

## Main Architecture Rule

The ViewModel must not communicate directly with external services.  
The ViewModel must communicate with repositories.

For the Microsoft Calendar integration, the official flow will be:

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
