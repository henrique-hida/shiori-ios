//
//  Languages.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

enum Language: Codable, CaseIterable {
    case english
    case portuguese
    case spanish
    
    static var currentSystemLanguage: Language {
        guard let systemCode = Locale.preferredLanguages.first else {
            return .english
        }
        if systemCode.starts(with: "pt") {
            return .portuguese
        } else if systemCode.starts(with: "es") {
            return .spanish
        } else {
            return .english
        }
    }
}
