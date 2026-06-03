//
//  DatabaseManager.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let databaseFileName = "acadplanner.sqlite"
    private var database: OpaquePointer?

    var connection: OpaquePointer? {
        database
    }

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(database)
    }

    func prepareStatement(_ query: String) -> OpaquePointer? {
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else {
            print("Unable to prepare SQLite statement.")
            return nil
        }

        return statement
    }

    func execute(_ query: String) {
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        } else {
            print("Unable to prepare SQLite statement.")
        }

        sqlite3_finalize(statement)
    }

    private func openDatabase() {
        let databaseURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(databaseFileName)

        guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK else {
            print("Unable to open SQLite database.")
            return
        }
    }

    private func createTables() {
        createSubjectTable()
        createTaskTable()
    }

    private func createSubjectTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS subjects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            professor TEXT NOT NULL,
            color_hex TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL
        );
        """

        execute(query)
    }

    private func createTaskTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS academic_tasks (
            id TEXT PRIMARY KEY,
            subject_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            due_date TEXT NOT NULL,
            priority TEXT NOT NULL,
            status TEXT NOT NULL,
            type TEXT NOT NULL,
            microsoft_event_id TEXT,
            is_added_to_calendar INTEGER NOT NULL,
            calendar_sync_status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL,
            FOREIGN KEY(subject_id) REFERENCES subjects(id)
        );
        """

        execute(query)
    }
}
