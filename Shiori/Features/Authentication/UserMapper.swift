//
//  UserMapper.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct UserMapper {
    static func map(
        request: SignUpRequest,
        id: String,
        initialNews: News,
        preferences: NewsPreferences
    ) -> AppUser {
        
        return AppUser(
            id: id,
            firstName: request.firstName,
            isPremium: request.isPremium,
            language: request.language,
            schema: request.schema,
            todayBackupNews: initialNews,
            newsPreferences: preferences
        )
    }
}
