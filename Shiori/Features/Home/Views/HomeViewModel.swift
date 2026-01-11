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
    var weekNewsSummaries: [Summary] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    var searchInput: String = ""
    var isPlayingLastNews: Bool = false
    
    private let syncService: NewsSyncService
    private let linkSummaryRepository: LinkSummaryRepositoryProtocol
    
    init(syncService: NewsSyncService, linkSummaryRepository: LinkSummaryRepositoryProtocol) {
        self.syncService = syncService
        self.linkSummaryRepository = linkSummaryRepository
    }
    
    func loadNews(for user: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weekNews = try await syncService.syncAndLoadWeek(for: user)
            self.weekNewsSummaries = weekNews
            
            if weekNews.isEmpty {
                self.errorMessage = "No news history found."
            }
            
        } catch {
            print("❌ Critical Error: \(error)")
            self.errorMessage = "Failed to load news database."
        }
        
        isLoading = false
    }
    
    func search() {
        
    }
    
    func handlePlayButtonClick() {
        isPlayingLastNews.toggle()
    }
}
