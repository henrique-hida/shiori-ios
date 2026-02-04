//
//  ReadLater.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation

struct ReadLater: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let title: String
    let content: String
    let thumbUrl: String
    let createdAt: Date
    let savedAt: Date
    let sources: [String]
    let subjects: [SummarySubject]
    let type: SummaryType
    
    var asSummary: Summary {
        Summary(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            thumbUrl: thumbUrl,
            sources: sources,
            subjects: subjects,
            type: type
        )
    }
    
    init(from data: ReadLaterData) {
        self.id = data.id
        self.title = data.title
        self.content = data.content
        self.thumbUrl = data.thumbUrl
        self.createdAt = data.createdAt
        self.savedAt = data.savedAt
        self.sources = data.sources
        self.subjects = data.subjects
        self.type = data.type
    }
}
