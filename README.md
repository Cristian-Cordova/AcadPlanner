AcadPlanner

AcadPlanner is an iOS application developed with SwiftUI to manage academic tasks by subject. It uses SQLite for local offline storage, Firebase Firestore for remote backup, and Google Calendar integration for academic task scheduling.

MVP Status

The current MVP allows users to:

* Manage subjects.
* Manage academic tasks.
* View a dashboard.
* Classify tasks by status, priority, and type.
* Store data locally with SQLite.
* Back up subjects and academic tasks with Firebase Firestore.
* Add academic tasks to Google Calendar.
* Persist calendar synchronization status locally and remotely.

Current Implementation

* Subject records are stored locally in SQLite and backed up to the Firestore subjects collection.
* AcademicTask records are stored locally in SQLite and backed up to the Firestore academic_tasks collection.
* Repositories keep the app offline-first by saving locally before attempting Firebase backup.
* Google Sign-In is used to authenticate the user before creating calendar events.
* Google Calendar API is used to create all-day events for academic tasks.
* Calendar event state is persisted through the task model after each calendar operation.
* Microsoft Graph was considered during development but was replaced by Google Calendar because the required Microsoft Entra ID configuration was not available.

Out of Scope for This MVP

The initial version does not include weather, motivational quotes, holidays, full calendar reading, bidirectional calendar synchronization, recurring events, advanced notifications, user collaboration, App Store deployment, or production-grade authentication.

Architecture

The project follows an architecture based on SwiftUI, MVVM, repositories, services, and data sources.

Views
↓
ViewModels
↓
Repositories
├── SQLite DataSources
├── Firebase DataSources
└── External Services

The persistence flow is:

SwiftUI View
↓
ViewModel
↓
Repository
↓
SQLite DataSource
↓
SQLite Database

For remote backup:

Repository
↓
Firebase DataSource
↓
Cloud Firestore

For Google Calendar integration:

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
TaskDetailViewModel
↓
TaskRepository
↓
SQLite + Firebase

This structure keeps SwiftUI views focused on presentation, ViewModels focused on screen state, repositories focused on coordination, and services focused on external integrations.

Firebase Configuration

Firebase uses GoogleService-Info.plist locally. This file is intentionally ignored by Git and must not be committed because it contains project configuration that should stay outside the public repository.

Google Calendar Configuration

Google Calendar integration requires local Google configuration and OAuth setup.

The project uses:

* Google Sign-In.
* Google Calendar API.
* iOS URL scheme configuration through Info.plist.
* A local GoogleService-Info.plist file excluded from Git.

No client secrets, access tokens, refresh tokens, private keys, .env files, or secret configuration files should be embedded in the iOS app or committed to GitHub.

Microsoft Graph Status

Microsoft Graph calendar integration was originally considered at the architecture level, but real authentication and event creation were not activated because they require a Microsoft Entra ID app registration, a client ID, a redirect URI, and delegated calendar permissions.

During development, the available Microsoft account did not have permission to create the required app registration or Microsoft 365 Developer sandbox. For this reason, the final MVP uses Google Calendar instead.

Microsoft Graph could be reconsidered in the future if the required Microsoft Entra ID configuration becomes available.

Release

Current academic MVP release:

v1.0.0-mvp

Release title:

AcadPlanner MVP - Final Academic Delivery

This release represents the final academic MVP delivery and is not intended to be a production-ready App Store version.

Documentation

Detailed MVP scope:

docs/mvp-scope.md

Instructor delivery report:

docs/final-delivery-report.md

Spanish academic documentation:

docs/documentacion-acadplanner-es.md
docs/Documentacion_AcadPlanner.docx