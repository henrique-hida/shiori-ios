//
//  LocalNewsRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import SwiftData

protocol LocalNewsRepositoryProtocol {
    func saveNews(_ summaries: Summary) async throws -> Void
    func fetchNews(forDate date: Date) throws -> Summary?
    func fetchWeekNews() throws -> [Summary]
}

@MainActor
final class LocalNewsRepository: LocalNewsRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
    func saveNews(_ summary: Summary) async throws {
        let id = summary.id
        let descriptor = FetchDescriptor<SummaryData>(predicate: #Predicate { $0.id == id })
        
        if let existing = try? context.fetch(descriptor).first {
            existing.title = summary.title
            existing.content = summary.content
            existing.createdAt = summary.createdAt
            existing.thumbUrl = summary.thumbUrl
            existing.sources = summary.sources
            existing.subjects = summary.subjects
            existing.type = summary.type
        } else {
            let newData = SummaryData(
                id: summary.id,
                title: summary.title,
                content: summary.content,
                createdAt: summary.createdAt,
                thumbUrl: summary.thumbUrl,
                sources: summary.sources,
                subjects: summary.subjects,
                type: summary.type
            )
            context.insert(newData)
        }
        
        try context.save()
        try deleteOldNews()
    }
    
    private func deleteOldNews() throws {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date()))!
        
        let descriptor = FetchDescriptor<SummaryData>(
            predicate: #Predicate { $0.createdAt < sevenDaysAgo }
        )
        
        let oldNews = try context.fetch(descriptor)
        for news in oldNews {
            context.delete(news)
        }
        
        try context.save()
    }
    
    
    func fetchNews(forDate date: Date) throws -> Summary? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<SummaryData>(
            predicate: #Predicate { $0.createdAt >= startOfDay && $0.createdAt < endOfDay }
        )
        
        guard let data = try context.fetch(descriptor).first else {
            return nil
        }
        
        return Summary(
            id: data.id,
            title: data.title,
            content: data.content,
            createdAt: data.createdAt,
            thumbUrl: data.thumbUrl,
            sources: data.sources,
            subjects: data.subjects,
            type: data.type
        )
    }
    
    func fetchWeekNews() throws -> [Summary] {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date()))!
        
        let descriptor = FetchDescriptor<SummaryData>(
            predicate: #Predicate { $0.createdAt >= sevenDaysAgo },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let savedData = try context.fetch(descriptor)
        
        return savedData.map { data in
            Summary(
                id: data.id,
                title: data.title,
                content: data.content,
                createdAt: data.createdAt,
                thumbUrl: data.thumbUrl,
                sources: data.sources,
                subjects: data.subjects,
                type: data.type
            )
        }
    }
}
