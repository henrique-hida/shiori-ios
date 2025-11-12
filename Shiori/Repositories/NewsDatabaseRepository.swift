//
//  NewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

struct NewsRequest: Sendable {
    var newsDuration: NewsDuration?
    var newsStyle: NewsStyle?
    var newsSubjects: [NewsSubject]?
    var newsLanguage: Language?
    var newsArriveTime: Int?
    
    private(set) var title: String?
    private(set) var content: String?
    private(set) var thumbLink: String?
    private(set) var date: Date?
    private(set) var articleLinks: [String]?
    var wasRead: Bool?
    
    init(newsDuration: NewsDuration, newsStyle: NewsStyle, newsSubjects: [NewsSubject], newsLanguage: Language, newsArriveTime: Int) {
        self.newsDuration = newsDuration
        self.newsStyle = newsStyle
        self.newsSubjects = newsSubjects
        self.newsLanguage = newsLanguage
        self.newsArriveTime = newsArriveTime
    }
    
    init(title: String, content: String, thumbLink: String, date: Date, articleLinks: [String], wasRead: Bool){
        self.title = title
        self.content = content
        self.thumbLink = thumbLink
        self.date = date
        self.articleLinks = articleLinks
        self.wasRead = wasRead
    }
}

protocol NewsDatabaseRepository {
    func getTodayNews(newsPreferences: NewsRequest) async throws -> NewsRequest
}
