//
//  AppUser.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

struct UserProfile: Codable, Identifiable, Equatable {
    let id: String?
    let firstName: String
    var isPremium: Bool
    var language: Language
    var theme: Theme
    var newsPreferences: NewsSummaryPreferences
}

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case portuguese = "pt"
    case spanish = "es"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .portuguese: return "Português"
        case .spanish: return "Español"
        }
    }
    
    var voiceIdentifier: String {
        switch self {
        case .english: return "en-US"
        case .portuguese: return "pt-BR"
        case .spanish: return "es-ES"
        }
    }
    
    static var currentSystemLanguage: Language {
        let code = Locale.preferredLanguages.first ?? "en"
        let prefix = String(code.prefix(2))
        return Language(rawValue: prefix) ?? .english
    }
}

enum Theme: Codable, CaseIterable {
    case light
    case dark
    case system
}


