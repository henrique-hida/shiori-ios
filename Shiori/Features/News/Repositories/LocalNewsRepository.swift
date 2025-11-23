//
//  LocalNewsRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import SwiftData

@MainActor
final class LocalNewsRepository: LocalNewsRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveNews(_ articles: [News]) async throws {
        for article in articles {
            let id = article.id
            let descriptor = FetchDescriptor<NewsData>(predicate: #Predicate { $0.id == id })
            
            if let existing = try? context.fetch(descriptor).first {
                existing.content = article.content
                existing.tone = article.tone
            } else {
                let newNews = NewsData(
                    id: article.id,
                    category: article.category,
                    content: article.content,
                    date: article.date,
                    tone: article.tone,
                    wasRead: article.wasRead
                )
                context.insert(newNews)
            }
        }
        try context.save()
    }
    
    func fetchNews(forDate date: Date) throws -> [News] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<NewsData>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        let savedNews = try context.fetch(descriptor)
        
        return savedNews.map { news in
            News(
                id: news.id,
                category: news.category,
                content: news.content,
                date: news.date,
                tone: news.tone,
                wasRead: news.wasRead
            )
        }
    }
    
    func updateReadStatus(newsID: String, wasRead: Bool) async throws {
        let descriptor = FetchDescriptor<NewsData>(predicate: #Predicate { $0.id == newsID })
        
        if let article = try context.fetch(descriptor).first {
            article.wasRead = wasRead
            try context.save()
        }
    }
}
