//
//  ReadingHistory.swift
//  Shiori
//
//  Created by Henrique Hida on 10/01/26.
//

import Foundation

struct ReadHistory: Identifiable, Codable, Sendable {
    let id: String
    let date: Date
    
    static func generateId(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
