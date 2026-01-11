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
    let thumbUrl: String
    let createdAt: Date
    let savedAt: Date
    
    init(from data: ReadLaterData) {
        self.id = data.id
        self.title = data.title
        self.thumbUrl = data.thumbUrl
        self.createdAt = data.createdAt
        self.savedAt = data.savedAt
    }
}
