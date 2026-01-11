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
    var linkSummaryStyle: SummaryStyle? = nil
    var linkSummaryDuration: SummaryDuration? = nil
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
    
    func search() async {
        guard !searchInput.isEmpty else { return }
        guard let style = linkSummaryStyle else { return }
        guard let duration = linkSummaryDuration else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let validatedURL = try verifyUrl(searchInput)
            let summary = try await linkSummaryRepo.summarizeLink(url: validatedURL, style: style, duration: duration)
            self.weekNewsSummaries.insert(summary, at: 0)
            self.searchInput = ""
            navigateToSummary(summary)
        } catch ValidationError.invalidFormat {
            self.errorMessage = "Please enter a valid web address (e.g., https://news.com)."
        } catch {
            print("❌ Search Error: \(error)")
            self.errorMessage = "We couldn't summarize this link. Please try another one."
        }
        
        isLoading = false
    }
    
    @discardableResult
    func verifyUrl(_ urlString: String) throws -> URL {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              url.host != nil else {
            throw ValidationError.invalidFormat
        }
        return url
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
