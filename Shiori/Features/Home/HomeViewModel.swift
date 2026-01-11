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
    
    var selectedSummary: Summary? = nil
    var searchInput: String = ""
    var validUrl: URL? = nil
    var linkSummaryStyle: SummaryStyle = .informal
    var linkSummaryDuration: SummaryDuration = .standard
    var shouldShowLinkSummarySettings: Bool = false
    var isPlayingLastNews: Bool = false
    
    private let syncService: NewsSyncServiceProtocol
    private let linkSummaryRepo: LinkSummaryRepositoryProtocol
    
    init(syncService: NewsSyncServiceProtocol, linkSummaryRepository: LinkSummaryRepositoryProtocol) {
        self.syncService = syncService
        self.linkSummaryRepo = linkSummaryRepository
    }
    
    func loadNews(for user: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weekNews = try await syncService.syncAndLoadWeek(for: user, isBackgroundTask: false)
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
    
    func search(url: URL) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let summary = try await linkSummaryRepo.summarizeLink(url: url, style: linkSummaryStyle, duration: linkSummaryDuration)
            self.weekNewsSummaries.insert(summary, at: 0)
            self.searchInput = ""
            self.validUrl = nil
            navigateToSummary(summary)
        } catch {
            print("❌ Search Error: \(error)")
            self.errorMessage = "We couldn't summarize this link. Please try another one."
        }
        
        isLoading = false
    }
    
    @discardableResult
    func isValidUrl(_ urlString: String) -> Bool {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              url.host != nil
        else {
            self.errorMessage = "Please enter a valid web address (e.g., https://news.com)."
            return false
        }
        validUrl = url
        return true
    }
    
    func navigateToSummary(_ summary: Summary) {
        self.selectedSummary = summary
    }
    
    enum ValidationError: Error {
        case invalidFormat
    }
    
    func handlePlayButtonClick() {
        isPlayingLastNews.toggle()
    }
}
