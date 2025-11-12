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
    var newsStyle: NewsStyle
    var newsSubjects: [NewsSubject]
    var newsLanguage: Language
    var newsArriveTime: Int
    
    init(newsDuration: NewsDuration, newsStyle: NewsStyle, newsSubjects: [NewsSubject], newsLanguage: Language, newsArriveTime: Int) {
        self.newsDuration = newsDuration
        self.newsStyle = newsStyle
        self.newsSubjects = newsSubjects
        self.newsLanguage = newsLanguage
        self.newsArriveTime = newsArriveTime
    }
}
