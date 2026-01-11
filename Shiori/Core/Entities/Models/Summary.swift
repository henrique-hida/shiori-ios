//
//  Summary.swift
//  Shiori
//
//  Created by Henrique Hida on 10/01/26.
//

import Foundation

struct Summary: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let thumbUrl: String
    let sources: [String]
    let subjects: [SummarySubject]
    let type: SummaryType
}
