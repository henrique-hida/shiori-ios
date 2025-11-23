//
//  NewsPreferences.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

struct NewsPreferences: Codable, Equatable {
    var duration: NewsDuration
    var style: NewsStyle
    var subjects: [NewsSubject]
    var language: Language
    var arriveTime: Int
}
