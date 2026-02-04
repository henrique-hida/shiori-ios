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
    
    var currentWeekStreak: [String: Bool] = [:]
    var currentWeekDates: [Date] = []
    var readLaterSummaries: [ReadLater] = []
    var subjectStats: [(subject: SummarySubject, percentage: Double)] = []
    
    var shouldShowLinkSummarySettings: Bool = false
    var shouldShowSettings: Bool = false
    var shouldShowHistorySheet: Bool = false
    var historySheetTab: Int = 0
    
    var cloudHistorySummaries: [Summary] = []
    var linkNewsSummaries: [Summary] = []
    
    private let syncService: NewsSyncServiceProtocol
    private let linkSummaryRepo: LinkSummaryRepositoryProtocol
    private let cloudLinkPersistence: LinkSummaryPersistenceProtocol
    private let cloudNewsRepo: CloudNewsRepositoryProtocol
    private let historyRepo: ReadingHistoryRepositoryProtocol
    private let readLaterRepo: ReadLaterRepositoryProtocol
    private let statsRepo: SubjectStatsRepositoryProtocol
    
    init(
        syncService: NewsSyncServiceProtocol,
        linkSummaryRepo: LinkSummaryRepositoryProtocol,
        cloudLinkPersistence: LinkSummaryPersistenceProtocol,
        cloudNewsRepo: CloudNewsRepositoryProtocol,
        historyRepo: ReadingHistoryRepositoryProtocol,
        readLaterRepo: ReadLaterRepositoryProtocol,
        statsRepo: SubjectStatsRepositoryProtocol,
    ){
        self.syncService = syncService
        self.linkSummaryRepo = linkSummaryRepo
        self.cloudLinkPersistence = cloudLinkPersistence
        self.cloudNewsRepo = cloudNewsRepo
        self.historyRepo = historyRepo
        self.readLaterRepo = readLaterRepo
        self.statsRepo = statsRepo
        self.generateCurrentWeek()
    }
    
    func generateCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }
        
        self.currentWeekDates = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: monday)
        }
    }
    
    func loadNews(for user: UserProfile) async {
        if weekNewsSummaries.isEmpty {
            isLoading = true
        }
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
    
    func search(url: URL, user: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let summary = try await linkSummaryRepo.summarizeLink(url: url, style: linkSummaryStyle, duration: linkSummaryDuration)
            if let userId = user.id {
                try? await cloudLinkPersistence.saveLinkSummary(summary, userId: userId)
            }
            
            self.linkNewsSummaries.insert(summary, at: 0)
            self.searchInput = ""
            self.validUrl = nil
            navigateToSummary(summary)
            
        } catch {
            print("❌ Search Error: \(error)")
            self.errorMessage = "We couldn't summarize this link. Please try another one."
        }
        
        isLoading = false
    }
    
    func loadLinkSummaries(user: UserProfile) async {
        guard linkNewsSummaries.isEmpty else { return }
        do {
            if let userId = user.id {
                let links = try await cloudLinkPersistence.fetchLinkSummaries(userId: userId)
                self.linkNewsSummaries = links
            }
        } catch {
            print("⚠️ Failed to load link summaries: \(error)")
        }
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

    func loadStreak() async {
        do {
            let activeDays = try await historyRepo.getHistory(for: currentWeekDates)
            var newStreakMap: [String: Bool] = [:]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            for date in currentWeekDates {
                let key = formatter.string(from: date)
                newStreakMap[key] = activeDays.contains(key)
            }
            
            self.currentWeekStreak = newStreakMap
        } catch {
            print("Failed to load streak: \(error)")
        }
    }

    func trackReadAction(user: UserProfile) {
        guard let summary = selectedSummary else { return }
        
        Task {
            try? await historyRepo.markTodayAsRead(user: user)
            await statsRepo.increment(subjects: summary.subjects)
            await loadStreak()
            await loadStats()
        }

    }
    
    func getDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func isFuture(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func loadReadLater() async {
        let summaries = await readLaterRepo.getAll()
        self.readLaterSummaries = summaries
    }

    func toggleReadLater(_ summary: Summary, user: UserProfile) {
        Task {
            if isReadLater(summary.id) {
                await readLaterRepo.remove(id: summary.id, user: user)
            } else {
                await readLaterRepo.save(summary, user: user)
            }
            await loadReadLater()
        }
    }

    func isReadLater(_ id: String) -> Bool {
        return readLaterSummaries.contains(where: { $0.id == id })
    }
    
    func loadStats() async {
        let year = Calendar.current.component(.year, from: Date())
        self.subjectStats = await statsRepo.getYearlyStats(year: year)
    }
    
    func loadMoreCloudHistory(user: UserProfile) async {
        guard !isLoading, cloudHistorySummaries.isEmpty else { return }
        isLoading = true
        
        let lastLocalDate = weekNewsSummaries.last?.createdAt ?? Date()
        
        do {
            let history = try await cloudNewsRepo.getPreviousNewsBatch(
                from: lastLocalDate,
                count: 23,
                preferences: user.newsPreferences
            )
            
            self.cloudHistorySummaries = history
            
        } catch {
            print("⚠️ Failed to load cloud history: \(error)")
        }
        
        isLoading = false
    }
}
