//
//  ReadingHistory.swift
//  Shiori
//
//  Created by Henrique Hida on 10/01/26.
//

import Foundation
import SwiftData

@Model
final class ReadingHistoryData {
    @Attribute(.unique) var id: String
    var date: Date
    
    init(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.id = formatter.string(from: date)
        self.date = date
    }
}
