//
//  News.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
final class SummaryData {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    var createdAt: Date
    var thumbUrl: String
    var sources: [String]
    var subjects: [SummarySubject]
    var type: SummaryType

    
    init(id: String, title: String, content: String, createdAt: Date, thumbUrl: String, sources: [String], subjects: [SummarySubject], type: SummaryType) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.thumbUrl = thumbUrl
        self.sources = sources
        self.subjects = subjects
        self.type = type
    }
}
