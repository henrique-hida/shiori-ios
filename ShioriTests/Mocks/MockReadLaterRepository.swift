//
//  MockReadLaterRepository.swift
//  ShioriTests
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
@testable import Shiori

struct MockReadLaterRepository: ReadLaterRepositoryProtocol {
    let mockSummary: Summary = Summary(
        id: "preview-news-1",
        title: "Daily Briefing 1",
        content: "This is a summary of news from 1 day ago.",
        createdAt: Date(),
        thumbUrl: "",
        sources: [],
        subjects: [.technology],
        type: .news
    )
    
    func getAll() async -> [Shiori.ReadLater] {
        return [ReadLater(from: ReadLaterData(summary: mockSummary))]
    }
    
    func save(_ summary: Shiori.Summary, user: Shiori.UserProfile) async {
        
    }
    
    func remove(id: String, user: Shiori.UserProfile) async {
        
    }
    
    func isSaved(id: String) -> Bool {
        return true
    }
    
    
}
