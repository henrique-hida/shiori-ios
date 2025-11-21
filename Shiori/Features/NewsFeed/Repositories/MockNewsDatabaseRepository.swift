//
//  MockNewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation

final class MockNewsDatabaseRepository: NewsDatabaseRepository {
    func getTodayNews(newsPreferences: NewsRequestBody) async throws -> NewsResponseDTO {
        return NewsResponseDTO(title: "Title", content: "Content", thumbLink: "https://link.com", date: Date(), articleLinks: ["https://link.com"], wasRead: false)
    }
}
