//
//  Subject.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation

struct Subject: Identifiable, Codable, Equatable
{
    let id: UUID
    var name: String
    var professor: String
    var colorHex: String
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        professor: String,
        colorHex: String = "#3B82F6",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSynced: Bool = false
    )
    {
        self.id = id
        self.name = name
        self.professor = professor
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
    }
}
