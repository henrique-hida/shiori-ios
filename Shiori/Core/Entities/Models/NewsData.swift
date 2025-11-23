//
//  News.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
final class NewsData {
    @Attribute(.unique) var id: String
    var category: String
    var content: String
    var date: Date
    var tone: String
    var wasRead: Bool
    
    init(id: String, category: String, content: String, date: Date, tone: String, wasRead: Bool) {
        self.id = id
        self.category = category
        self.content = content
        self.date = date
        self.tone = tone
        self.wasRead = wasRead
    }
}
