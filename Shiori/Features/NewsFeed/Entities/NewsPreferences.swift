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
    private var newsDurationRaw: String
    private var newsStyleRaw: String
    private var newsSubjectsRaw: [String]
    private var newsLanguageRaw: String
    
    var newsArriveTime: Int
    
    @Transient
    var newsDuration: NewsDuration {
        get { NewsDuration(rawValue: newsDurationRaw) ?? .standard }
        set { newsDurationRaw = newValue.rawValue }
    }
    
    @Transient
    var newsStyle: NewsStyle {
        get { NewsStyle(rawValue: newsStyleRaw) ?? .imparcial }
        set { newsStyleRaw = newValue.rawValue }
    }
    
    @Transient
    var newsLanguage: Language {
        get { Language(rawValue: newsLanguageRaw) ?? .english }
        set { newsLanguageRaw = newValue.rawValue }
    }
    
    @Transient
    var newsSubjects: [NewsSubject] {
        get { newsSubjectsRaw.compactMap { NewsSubject(rawValue: $0) }}
        set { newsSubjectsRaw = newValue.map { $0.rawValue }}
    }
    
    init(
        newsDuration: NewsDuration,
        newsStyle: NewsStyle,
        newsSubjects: [NewsSubject],
        newsLanguage: Language,
        newsArriveTime: Int
    ) {
        self.newsDurationRaw = newsDuration.rawValue
        self.newsStyleRaw = newsStyle.rawValue
        self.newsSubjectsRaw = newsSubjects.map { $0.rawValue }
        self.newsLanguageRaw = newsLanguage.rawValue
        self.newsArriveTime = newsArriveTime
    }
}
