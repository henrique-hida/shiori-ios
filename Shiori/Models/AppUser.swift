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
    var systemLanguage: Language
    var isDarkSchemePrefered: Bool
    var todayBackupNews: News
    var newsPreferences: NewsPreferences
    
    init(id: String, firstName: String, isPremium: Bool, systemLanguage: Language, isDarkSchemePrefered: Bool, todayBackupNews: News, newsPreferences: NewsPreferences) {
        self.id = id
        self.firstName = firstName
        self.isPremium = isPremium
        self.systemLanguage = systemLanguage
        self.isDarkSchemePrefered = isDarkSchemePrefered
        self.todayBackupNews = todayBackupNews
        self.newsPreferences = newsPreferences
    }
}
