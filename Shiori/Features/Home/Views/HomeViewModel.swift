//
//  HomeViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var newsArticles: [News] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    private let localRepo: LocalNewsRepositoryProtocol
    private let cloudRepo: CloudNewsRepositoryProtocol
    
    init(localRepo: LocalNewsRepositoryProtocol, cloudRepo: CloudNewsRepositoryProtocol) {
        self.localRepo = localRepo
        self.cloudRepo = cloudRepo
    }
    
    func loadNews(for user: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let today = Date()
            let localNews = try localRepo.fetchNews(forDate: today)
            
            if !localNews.isEmpty {
                self.newsArticles = localNews.map {
                    News(id: $0.id, category: $0.category, content: $0.content, date: $0.date, tone: $0.tone, wasRead: $0.wasRead)
                }
            } else {
                let fetchedArticles = try await cloudRepo.getTodayNews(preferences: user.newsPreferences)
                let dbObjects = fetchedArticles.map {
                    News(id: $0.id, category: $0.category, content: $0.content, date: $0.date, tone: $0.tone, wasRead: false)
                }
                try await localRepo.saveNews(dbObjects)
                
                self.newsArticles = fetchedArticles
            }
        } catch {
            print("❌ News Load Error: \(error)")
            self.errorMessage = "Failed to load news."
        }
        
        isLoading = false
    }
}
