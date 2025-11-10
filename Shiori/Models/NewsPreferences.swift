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
    var newsDuration: NewsDurations
    var newsStyles: NewsStyles
    var newsSubjects: [NewsSubjects]
    var newsLanguages: Languages
    var newsArriveTime: Int
    
    init(newsDuration: NewsDurations, newsStyles: NewsStyles, newsSubjects: [NewsSubjects], newsLanguages: Languages, newsArriveTime: Int) {
        self.newsDuration = newsDuration
        self.newsStyles = newsStyles
        self.newsSubjects = newsSubjects
        self.newsLanguages = newsLanguages
        self.newsArriveTime = newsArriveTime
    }
}
