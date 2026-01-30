//
//  UserSample.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import Foundation

extension UserProfile {
    static var sampleUser = UserProfile(
        id: "preview_user",
        firstName: "Previewer",
        isPremium: true,
        language: .english,
        theme: .system,
        newsPreferences: NewsSummaryPreferences(
            duration: .standard,
            style: .funny,
            subjects: [],
            language: .english,
            arriveTime: 8
        )
    )
}
