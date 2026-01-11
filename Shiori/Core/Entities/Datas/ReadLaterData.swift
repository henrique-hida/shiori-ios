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
    var thumbUrl: String
    var createdAt: Date
    var savedAt: Date
    
    init(summary: Summary) {
        self.id = summary.id
        self.title = summary.title
        self.thumbUrl = summary.thumbUrl
        self.createdAt = summary.createdAt
        self.savedAt = Date()
    }
}
