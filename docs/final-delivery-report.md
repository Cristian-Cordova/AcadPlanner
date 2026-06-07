# AcadPlanner Final Delivery Report

## Project Overview

AcadPlanner is an iOS academic task planner built with SwiftUI. The application helps students organize subjects and academic tasks, classify assignments by priority, status, and type, and maintain offline access to their academic information through SQLite local storage.

The project was developed as an academic MVP focused on reliability, clean architecture, local persistence, remote backup, and calendar integration for academic deadlines.

## Current MVP Status

The MVP includes a functional SwiftUI interface with the following screens:

- Dashboard
- Task List
- Task Detail
- Task Form
- Subject List
- Subject Form

The application supports creating, editing, deleting, and viewing subjects and academic tasks. It also allows academic tasks to be added to Google Calendar from the task detail screen.

## Implemented Technologies

- SwiftUI for the user interface.
- MVVM for screen state and presentation logic.
- Repository pattern for data access abstraction.
- SQLite for local offline storage.
- Firebase Firestore for remote backup.
- Google Sign-In for authentication.
- Google Calendar API for academic task scheduling.
- Async/await for asynchronous operations.
- Git and GitHub for version control and delivery tracking.

## Architecture

AcadPlanner follows a layered architecture:

```text
SwiftUI Views
↓
ViewModels
↓
Repositories
├── SQLite DataSources
├── Firebase DataSources
└── External Services
```

This structure separates responsibilities clearly:

- Views handle presentation and user interaction.
- ViewModels manage screen state and user actions.
- Repositories coordinate data operations.
- DataSources handle local and remote persistence.
- Services handle external integrations such as Google authentication and calendar event creation.

This architecture keeps the project maintainable and avoids placing database, Firebase, or API logic directly inside SwiftUI views.

## Local Storage

Subjects and academic tasks are stored locally using SQLite. This allows the application to work even without an internet connection and preserves the user's information after closing and reopening the app.

SQLite is the primary source of persistence in the MVP because it provides reliable offline behavior, fast local access, and direct control over the stored academic data.

## Firebase Backup

The app backs up subjects and academic tasks to Firebase Firestore after saving them locally.

The repository layer follows a local-first strategy:

```text
Save to SQLite
↓
Attempt Firebase backup
↓
Keep local data safe even if Firebase fails
```

If Firebase backup fails, the local data remains available because SQLite is updated first.

Firestore collections used by the project:

- `subjects`
- `academic_tasks`

## Google Calendar Integration

The final delivery includes a functional Google Calendar integration. This replaced the originally planned Microsoft Calendar flow because Microsoft Graph required external Microsoft Entra ID configuration that was not available during development.

### Integration Flow

```text
TaskDetailView
↓
TaskDetailViewModel
↓
CalendarRepository
↓
GoogleAuthService
↓
GoogleCalendarService
↓
Google Calendar API
↓
TaskRepository
↓
SQLite + Firebase
```

This flow keeps the ViewModel independent from Google Calendar implementation details. The ViewModel communicates with `CalendarRepository`, while the repository coordinates authentication, event creation, and task state updates.

### Event Creation

Academic tasks are created as all-day events in Google Calendar.

The app uses:

- `start.date`
- `end.date`

This is appropriate for academic deadlines because assignments, exams, and projects usually represent due dates rather than meetings with a specific hour.

For all-day events, the `end.date` is set to the following day. This matches Google Calendar's expected behavior for all-day events.

### htmlLink Support

The app reads the `htmlLink` field returned by the Google Calendar API.

This allows the application to provide a direct link to the created event in Google Calendar, giving the user a simple way to verify that the event was successfully created.

### Calendar State Persistence

After attempting to add a task to Google Calendar, the app persists the calendar state.

On success:

- The Google Calendar event ID is saved.
- `isAddedToCalendar` is set to `true`.
- `calendarSyncStatus` is set to `added`.
- The updated task is saved to SQLite.
- The updated task is backed up to Firebase.

On failure:

- `calendarSyncStatus` is set to `failed`.
- The failed state is saved locally.
- An error message is shown in the interface.

This approach prevents the app from losing task information if calendar synchronization fails.

## Microsoft Calendar Integration Status

Microsoft Calendar integration was originally considered through a prepared architecture involving:

- `CalendarRepository`
- `MicrosoftAuthService`
- `MicrosoftCalendarService`
- `microsoftEventId`
- `calendarSyncStatus`

However, real Microsoft Graph activation requires a Microsoft Entra ID app registration, redirect URI, client ID, and delegated `Calendars.ReadWrite` permission.

During development, the available Microsoft account could not create the required app registration because it did not have access to a valid Entra ID tenant or Microsoft 365 Developer sandbox.

Because of this external configuration limitation, the final MVP uses Google Calendar instead. This does not affect the architecture negatively, because the repository and service-based design allows the calendar provider to be replaced without changing the SwiftUI views.

## Files Modified for Google Calendar

The main files involved in the Google Calendar integration are:

- `GoogleAuthService.swift`
- `GoogleCalendarService.swift`
- `CalendarRepository.swift`
- `TaskDetailViewModel.swift`
- `TaskDetailView.swift`
- `Info.plist`
- `project.pbxproj`
- `Package.resolved`

## Security Notes

The project uses Firebase and Google Sign-In configuration locally.

The file `GoogleService-Info.plist` must not be committed to GitHub if it contains sensitive or environment-specific configuration.

The repository must not include:

- Client secrets
- Access tokens
- Refresh tokens
- Private keys
- `.env` files
- Secret Firebase configuration files
- Private API credentials

This protects the project from exposing authentication credentials or external service configuration publicly.

## Delivery Summary

AcadPlanner delivers a stable academic MVP with:

- Functional SwiftUI interface.
- Subject management.
- Academic task management.
- SQLite local persistence.
- Firebase Firestore backup.
- Google Calendar integration.
- Clean MVVM architecture.
- Repository-based data access.
- Separation between presentation, persistence, and external services.
- Verified successful build with `BUILD SUCCEEDED`.

The final version is suitable for academic delivery and provides a solid base for future improvements toward a more professional production-ready application.
