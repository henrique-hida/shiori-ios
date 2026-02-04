//
//  Summary.swift
//  Shiori
//
//  Created by Henrique Hida on 10/01/26.
//

import Foundation

struct Summary: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let thumbUrl: String
    let sources: [String]
    let subjects: [SummarySubject]
    let type: SummaryType
    
    var summaryData: SummaryData {
        SummaryData(
            id: self.id,
            title: self.title,
            content: self.content,
            createdAt: self.createdAt,
            thumbUrl: self.thumbUrl,
            sources: self.sources,
            subjects: self.subjects,
            type: self.type
        )
    }
        
}

enum SummaryType: String, Codable, Sendable {
    case news = "news"
    case link = "link"
}
