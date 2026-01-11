//
//  NewsPreferences.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

struct NewsSummaryPreferences: Codable, Equatable {
    var duration: SummaryDuration
    var style: SummaryStyle
    var subjects: [SummarySubject]
    var language: Language
    var arriveTime: Int
}
