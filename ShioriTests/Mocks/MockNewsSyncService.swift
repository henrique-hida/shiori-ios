//
//  MockNewsSyncService.swift
//  ShioriTests
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
@testable import Shiori

struct MockNewsSyncService: NewsSyncRepositoryProtocol {
    func syncAndLoadWeek(for user: Shiori.UserProfile, isBackgroundTask: Bool) async throws -> [Shiori.Summary] {
        return [Summary(
            id: "preview-news-1",
            title: "Daily Briefing 1",
            content: "This is a summary of news from 1 day ago.",
            createdAt: Date(),
            thumbUrl: "",
            sources: [],
            subjects: [.technology],
            type: .news
        )]
    }
}
