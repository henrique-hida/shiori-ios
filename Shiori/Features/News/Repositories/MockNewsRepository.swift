//
//  MockNewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation

final class MockNewsDatabaseRepository: CloudNewsRepositoryProtocol {
    func getTodayNews(preferences: NewsPreferences) async throws -> [News] {
        return [
            News(
                id: "mock-1",
                category: "Technology",
                content: "Apple releases new AI features...",
                date: Date(),
                tone: "fast",
                wasRead: false
            ),
            News(
                id: "mock-2",
                category: "Politics",
                content: "Elections are coming up...",
                date: Date(),
                tone: "fast",
                wasRead: true
            )
        ]
    }
}
