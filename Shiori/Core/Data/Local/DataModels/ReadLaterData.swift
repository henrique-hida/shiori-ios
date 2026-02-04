//
//  ReadLaterData.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
import SwiftData

@Model
final class ReadLaterData {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    var thumbUrl: String
    var createdAt: Date
    var savedAt: Date
    var sources: [String]
    var subjects: [SummarySubject]
    var type: SummaryType
    
    init(summary: Summary) {
        self.id = summary.id
        self.title = summary.title
        self.content = summary.content
        self.thumbUrl = summary.thumbUrl
        self.createdAt = summary.createdAt
        self.savedAt = Date()
        self.sources = summary.sources
        self.subjects = summary.subjects
        self.type = summary.type
    }
}
