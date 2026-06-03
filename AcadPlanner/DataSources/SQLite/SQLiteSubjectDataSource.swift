//
//  SQLiteSubjectDataSource.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import SQLite3

final class SQLiteSubjectDataSource
{
    private let databaseManager: DatabaseManager
    private let dateFormatter = ISO8601DateFormatter()

    init(databaseManager: DatabaseManager = .shared)
    {
        self.databaseManager = databaseManager
    }

    func fetchSubjects() -> [Subject]
    {
        databaseManager.sync {
            let query = """
            SELECT id, name, professor, color_hex, created_at, updated_at, is_synced
            FROM subjects
            ORDER BY name ASC;
            """

            guard let statement = databaseManager.prepareStatement(query)
            else { return [] }

            var subjects: [Subject] = []

            while sqlite3_step(statement) == SQLITE_ROW
            {
                if let subject = makeSubject(from: statement)
                {
                    subjects.append(subject)
                }
            }

            sqlite3_finalize(statement)
            return subjects
        }
    }

    func fetchSubject(id: UUID) -> Subject?
    {
        databaseManager.sync {
            let query = """
            SELECT id, name, professor, color_hex, created_at, updated_at, is_synced
            FROM subjects
            WHERE id = ?;
            """

            guard let statement = databaseManager.prepareStatement(query)
            else { return nil }

            bindText(id.uuidString, to: statement, at: 1)

            let subject = sqlite3_step(statement) == SQLITE_ROW
                ? makeSubject(from: statement)
                : nil

            sqlite3_finalize(statement)
            return subject
        }
    }

    @discardableResult
    func saveSubject(_ subject: Subject) -> Subject
    {
        if fetchSubject(id: subject.id) == nil
        {
            insertSubject(subject)
        }
        else
        {
            updateSubject(subject)
        }
        return subject
    }

    func deleteSubject(id: UUID)
    {
        databaseManager.sync {
            let query = "DELETE FROM subjects WHERE id = ?;"

            guard let statement = databaseManager.prepareStatement(query)
            else { return }

            bindText(id.uuidString, to: statement, at: 1)
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }

    private func insertSubject(_ subject: Subject)
    {
        databaseManager.sync {
            let query = """
            INSERT INTO subjects (
                id, name, professor, color_hex, created_at, updated_at, is_synced
            )
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """

            guard let statement = databaseManager.prepareStatement(query)
            else { return }

            bindSubject(subject, to: statement)
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }

    private func updateSubject(_ subject: Subject)
    {
        databaseManager.sync {
            let query = """
            UPDATE subjects
            SET name = ?,
                professor = ?,
                color_hex = ?,
                created_at = ?,
                updated_at = ?,
                is_synced = ?
            WHERE id = ?;
            """

            guard let statement = databaseManager.prepareStatement(query)
            else { return }

            bindText(subject.name, to: statement, at: 1)
            bindText(subject.professor, to: statement, at: 2)
            bindText(subject.colorHex, to: statement, at: 3)
            bindText(dateFormatter.string(from: subject.createdAt), to: statement, at: 4)
            bindText(dateFormatter.string(from: subject.updatedAt), to: statement, at: 5)
            sqlite3_bind_int(statement, 6, subject.isSynced ? 1 : 0)
            bindText(subject.id.uuidString, to: statement, at: 7)

            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }

    private func bindSubject(_ subject: Subject, to statement: OpaquePointer?)
    {
        bindText(subject.id.uuidString, to: statement, at: 1)
        bindText(subject.name, to: statement, at: 2)
        bindText(subject.professor, to: statement, at: 3)
        bindText(subject.colorHex, to: statement, at: 4)
        bindText(dateFormatter.string(from: subject.createdAt), to: statement, at: 5)
        bindText(dateFormatter.string(from: subject.updatedAt), to: statement, at: 6)
        sqlite3_bind_int(statement, 7, subject.isSynced ? 1 : 0)
    }

    private func makeSubject(from statement: OpaquePointer?) -> Subject?
    {
        guard
            let idText = sqlite3_column_text(statement, 0),
            let nameText = sqlite3_column_text(statement, 1),
            let professorText = sqlite3_column_text(statement, 2),
            let colorHexText = sqlite3_column_text(statement, 3),
            let createdAtText = sqlite3_column_text(statement, 4),
            let updatedAtText = sqlite3_column_text(statement, 5),
            let id = UUID(uuidString: String(cString: idText))
        else { return nil }

        return Subject(
            id: id,
            name: String(cString: nameText),
            professor: String(cString: professorText),
            colorHex: String(cString: colorHexText),
            createdAt: dateFormatter.date(from: String(cString: createdAtText)) ?? Date(),
            updatedAt: dateFormatter.date(from: String(cString: updatedAtText)) ?? Date(),
            isSynced: sqlite3_column_int(statement, 6) == 1
        )
    }

    private func bindText(_ value: String, to statement: OpaquePointer?, at index: Int32)
    {
        let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, index, value, -1, sqliteTransient)
    }
}
