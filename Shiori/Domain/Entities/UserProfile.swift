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
