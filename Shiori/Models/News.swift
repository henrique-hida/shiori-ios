//
//  News.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
class News {
    private(set) var title: String
    private(set) var content: String
    private(set) var thumbLink: String
    private(set) var date: Date
    private(set) var articleLinks: [String]
    var wasRead: Bool
    
    init(title: String, content: String, thumbLink: String, date: Date, articleLinks: [String], wasRead: Bool) {
        self.title = title
        self.content = content
        self.thumbLink = thumbLink
        self.date = date
        self.articleLinks = articleLinks
        self.wasRead = wasRead
    }
}
