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
    
    private let syncService: NewsSyncService
    
    init(syncService: NewsSyncService) {
        self.syncService = syncService
    }
    
    func loadNews(for user: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weekNews = try await syncService.syncAndLoadWeek(for: user)
            self.newsArticles = weekNews
            
            if weekNews.isEmpty {
                self.errorMessage = "No news history found."
            }
            
        } catch {
            print("❌ Critical Error: \(error)")
            self.errorMessage = "Failed to load news database."
        }
        
        isLoading = false
    }
}
