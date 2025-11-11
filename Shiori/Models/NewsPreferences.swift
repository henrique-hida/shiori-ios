//
//  NewsPreferences.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
class NewsPreferences {
    var newsDuration: NewsDuration
    var newsStyles: NewsStyle
    var newsSubjects: [NewsSubject]
    var newsLanguages: Language
    var newsArriveTime: Int
    
    init(newsDuration: NewsDuration, newsStyles: NewsStyle, newsSubjects: [NewsSubject], newsLanguages: Language, newsArriveTime: Int) {
        self.newsDuration = newsDuration
        self.newsStyles = newsStyles
        self.newsSubjects = newsSubjects
        self.newsLanguages = newsLanguages
        self.newsArriveTime = newsArriveTime
    }
}
