//
//  AppUser.swift
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

    private var languageRaw: String
    private var schemaRaw: String
    
    var todayBackupNews: News
    var newsPreferences: NewsPreferences
    
    @Transient
    var language: Language {
        get { Language(rawValue: languageRaw) ?? .english }
        set { languageRaw = newValue.rawValue }
    }
    
    @Transient
    var schema: Theme {
        get { Theme(rawValue: schemaRaw) ?? .system }
        set { schemaRaw = newValue.rawValue }
    }
    
    init(
        id: String,
        firstName: String,
        isPremium: Bool,
        language: Language,
        schema: Theme,
        todayBackupNews: News,
        newsPreferences: NewsPreferences
    ) {
        self.id = id
        self.firstName = firstName
        self.isPremium = isPremium
        self.languageRaw = language.rawValue
        self.schemaRaw = schema.rawValue
        self.todayBackupNews = todayBackupNews
        self.newsPreferences = newsPreferences
    }
}
