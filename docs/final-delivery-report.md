# AcadPlanner Final Delivery Report

## Project Overview

AcadPlanner is an iOS academic task planner built with SwiftUI. The application helps students organize subjects and academic tasks, classify work by priority, status, and type, and keep local access to their information through SQLite.

## Current MVP Status

The MVP includes a functional SwiftUI interface with a dashboard, task list, task detail screen, task form, subject list, and subject form. The app supports creating, editing, deleting, and viewing subjects and academic tasks.

## Implemented Technologies

- SwiftUI for the user interface.
- MVVM for screen state and presentation logic.
- Repository pattern for data access abstraction.
- SQLite for local offline storage.
- Firebase Firestore for remote backup.
- Prepared Microsoft Calendar architecture for future Microsoft Graph integration.

## Architecture

The project follows a layered architecture:

```text
SwiftUI Views
↓
ViewModels
↓
Repositories
├── SQLite DataSources
└── Firebase DataSources
```

This structure keeps views focused on presentation, ViewModels focused on screen state, repositories focused on data coordination, and data sources focused on persistence or remote backup.

## Local Storage

Subjects and academic tasks are stored locally using SQLite. This allows the app to keep working even without internet access and preserves data after closing and reopening the app.

## Firebase Backup

The app backs up subjects and academic tasks to Firebase Firestore after saving them locally. The repository layer saves to SQLite first, then attempts the Firebase backup. If Firebase fails, the local data remains safe.

Firestore collections:

- `subjects`
- `academic_tasks`

## Microsoft Calendar Integration Status

Microsoft Calendar integration is prepared at the architecture level through:

- `CalendarRepository`
- `MicrosoftAuthService`
- `MicrosoftCalendarService`
- `microsoftEventId`
- `calendarSyncStatus`

The current MVP uses a controlled mock calendar flow. Real Microsoft Graph activation requires a Microsoft Entra ID app registration, redirect URI, client ID, and delegated `Calendars.ReadWrite` permission.

During development, the current Microsoft account could not create the required app registration because it did not have access to a valid Entra ID tenant or Microsoft 365 Developer sandbox. This is an external configuration limitation, not an application architecture issue.

## Security Notes

The Firebase configuration file `GoogleService-Info.plist` is used locally but intentionally ignored by Git. The project must not commit client secrets, access tokens, refresh tokens, private keys, `.env` files, or secret configuration files.

## Delivery Summary

AcadPlanner currently provides a stable academic MVP with local persistence, remote backup, clean architecture, and a prepared path for Microsoft Graph calendar integration. The main functional requirements for SwiftUI, SQLite, Firebase, MVVM, repositories, and structured project organization are implemented.
