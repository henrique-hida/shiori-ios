//
//  NewsSamples.swift
//  Shiori
//
//  Created by Henrique Hida on 27/01/26.
//

import Foundation

extension Summary {
    static let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
    static let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date.now)!
    static var sampleBooks: [Summary] {
        [
            
        ]
    }
}
