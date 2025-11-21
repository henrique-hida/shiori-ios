//
//  NewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

protocol NewsDatabaseRepository {
    func getTodayNews(newsPreferences: NewsRequestBody) async throws -> NewsResponseDTO
}
