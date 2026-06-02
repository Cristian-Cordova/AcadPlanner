# AcadPlanner

AcadPlanner is an iOS application developed with SwiftUI to manage academic tasks by subject. It uses SQLite for local storage, Firebase for remote backup/synchronization, and Microsoft Calendar integration through Microsoft Graph.

## MVP

The MVP allows users to:

- Manage subjects.
- Manage academic tasks.
- View a dashboard.
- Classify tasks by status, priority, and type.
- Store data locally with SQLite.
- Back up data with Firebase.
- Create Microsoft Calendar events from existing tasks.

## Initial Out of Scope

The initial version does not include Google Calendar, weather, motivational quotes, holidays, full calendar reading, bidirectional synchronization, or user collaboration.

## Architecture

The project follows an architecture based on SwiftUI, MVVM, repositories, services, and data sources.

```text
Views
↓
ViewModels
↓
Repositories
↓
DataSources / Services
```

For Microsoft Calendar integration:

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

## Documentation

Detailed MVP scope:

```text
docs/mvp-scope.md
```
