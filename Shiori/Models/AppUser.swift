//
//  LocalUser.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
class AppUser {
    @Attribute(.unique) private(set) var id: String
    private(set) var firstName: String
    var isPremium: Bool
    var language: Language
    var schema: Theme
    var todayBackupNews: News
    var newsPreferences: NewsPreferences
    
    init(id: String, firstName: String, isPremium: Bool, language: Language, schema: Theme, todayBackupNews: News, newsPreferences: NewsPreferences) {
        self.id = id
        self.firstName = firstName
        self.isPremium = isPremium
        self.language = language
        self.schema = schema
        self.todayBackupNews = todayBackupNews
        self.newsPreferences = newsPreferences
    }
}
