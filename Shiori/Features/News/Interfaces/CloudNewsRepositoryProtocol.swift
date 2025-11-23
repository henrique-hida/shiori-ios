//
//  NewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

protocol CloudNewsRepositoryProtocol {
    func getTodayNews(preferences: NewsPreferences) async throws -> [News]
}
