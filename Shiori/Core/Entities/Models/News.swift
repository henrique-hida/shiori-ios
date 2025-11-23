//
//  NewsArticle.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation

struct News: Identifiable, Sendable, Codable {
    let id: String
    let category: String
    let content: String
    let date: Date
    let tone: String
    var wasRead: Bool
}
