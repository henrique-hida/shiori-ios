//
//  Languages.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

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
    
    static var currentSystemLanguage: Language {
        let code = Locale.preferredLanguages.first ?? "en"
        let prefix = String(code.prefix(2))
        return Language(rawValue: prefix) ?? .english
    }
}
