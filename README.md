# AcadPlanner

AcadPlanner is an iOS application developed with SwiftUI to manage academic tasks by subject. It uses SQLite for local offline storage, Firebase Firestore for remote backup, and a prepared Microsoft Calendar integration layer for future Microsoft Graph activation.

## MVP Status

The current MVP allows users to:

- Manage subjects.
- Manage academic tasks.
- View a dashboard.
- Classify tasks by status, priority, and type.
- Store data locally with SQLite.
- Back up subjects and academic tasks with Firebase Firestore.
- Track whether a task has been marked as added to Microsoft Calendar.

## Current Implementation

- `Subject` records are stored locally in SQLite and backed up to the Firestore `subjects` collection.
- `AcademicTask` records are stored locally in SQLite and backed up to the Firestore `academic_tasks` collection.
- Repositories keep the app offline-first by saving locally before attempting Firebase backup.
- Microsoft Calendar currently uses a controlled mock event ID through `CalendarRepository`.
- Real Microsoft Graph activation requires a Microsoft Entra ID app registration, a client ID, a redirect URI, and delegated calendar permissions.

## Out of Scope for This MVP

The initial version does not include Google Calendar, weather, motivational quotes, holidays, full Microsoft Calendar reading, bidirectional calendar synchronization, recurring events, advanced notifications, or user collaboration.

## Architecture

The project follows an architecture based on SwiftUI, MVVM, repositories, services, and data sources.

```text
Views
↓
ViewModels
↓
Repositories
├── SQLite DataSources
└── Firebase DataSources
```

The persistence flow is:

```text
SwiftUI View
↓
ViewModel
↓
Repository
↓
SQLite DataSource
↓
SQLite Database
```

For remote backup:

```text
Repository
↓
Firebase DataSource
↓
Cloud Firestore
```

For the planned Microsoft Calendar integration:

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

## Firebase Configuration

Firebase uses `GoogleService-Info.plist` locally. This file is intentionally ignored by Git and must not be committed because it contains project configuration that should stay outside the public repository.

## Microsoft Graph Status

Microsoft Graph calendar integration is prepared at the architecture level, but real authentication and event creation are not activated in this MVP because they require a Microsoft Entra ID app registration. The current account used during development did not have permission to create the required app registration or Microsoft 365 Developer sandbox.

To activate this feature later, the project will need:

- Microsoft Entra ID app registration.
- iOS/macOS platform configuration.
- Bundle ID: `com.cristiancordova.AcadPlanner`.
- Redirect URI: `msauth.com.cristiancordova.AcadPlanner://auth`.
- Microsoft Graph delegated permission: `Calendars.ReadWrite`.
- MSAL-based user authentication.

No client secrets, access tokens, refresh tokens, private keys, `.env` files, or secret configuration files should be embedded in the iOS app or committed to GitHub.

## Documentation

Detailed MVP scope:

```text
docs/mvp-scope.md
```

Instructor delivery report:

```text
docs/final-delivery-report.md
```
