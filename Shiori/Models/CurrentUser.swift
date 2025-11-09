//
//  CurrentUser.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
class CurrentUser {
    @Attribute(.unique) private(set) var id: String
    private(set) var firstName: String
    var isPremium: Bool
    var systemLanguage: String
    var isThemeDarkPrefered: Bool
    var todayBackupNews: String
    
    init(id: String, firstName: String, isPremium: Bool, systemLanguage: String, isThemeDarkPrefered: Bool, todayBackupNews: String) {
        self.id = id
        self.firstName = firstName
        self.isPremium = isPremium
        self.systemLanguage = systemLanguage
        self.isThemeDarkPrefered = isThemeDarkPrefered
        self.todayBackupNews = todayBackupNews
    }
}
