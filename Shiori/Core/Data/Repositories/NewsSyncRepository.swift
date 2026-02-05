//
//  NewsSyncService.swift
//  Shiori
//
//  Created by Henrique Hida on 16/12/25.
//

import Foundation
import UserNotifications

@MainActor
final class NewsSyncRepository: NewsSyncRepositoryProtocol {
    private let localNewsService: LocalNewsSourceProtocol
    private let networkNewsService: NetworkNewsSourceProtocol
    
    init(localNewsService: LocalNewsSourceProtocol, networkNewsService: NetworkNewsSourceProtocol) {
        self.localNewsService = localNewsService
        self.networkNewsService = networkNewsService
    }

    func syncAndLoadWeek(for user: UserProfile, isBackgroundTask: Bool = false) async throws -> [Summary] {
        let calendar = Calendar.current
        let today = Date()
        
        let last7Days = (0..<7).compactMap { i -> Date? in
            calendar.date(byAdding: .day, value: -i, to: today)
        }
        
        let existingNews = try localNewsService.fetchWeekNews()
        let existingDateKeys = Set(existingNews.map { formatDateKey($0.createdAt) })
        let missingDates = last7Days.filter { date in
            let key = formatDateKey(date)
            return !existingDateKeys.contains(key)
        }
        
        if missingDates.isEmpty {
            print("✅ Local cache is complete for the week.")
        } else {
            print("🌍 Missing \(missingDates.count) days. Attempting to backfill from Cloud...")
            
            await withTaskGroup(of: Void.self) { group in
                for date in missingDates {
                    group.addTask {
                        do {
                            let summary = try await self.networkNewsService.getNews(for: date, preferences: user.newsPreferences)
                            try await self.localNewsService.saveNews(summary)
                            print("✅ Backfilled news for: \(await self.formatDateKey(date))")
                        } catch {
                            print("⚠️ Failed to fetch for \(await self.formatDateKey(date)): \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            if isBackgroundTask {
                let todayKey = formatDateKey(today)
                if missingDates.contains(where: { formatDateKey($0) == todayKey }) {
                     scheduleArrivalNotification(for: user)
                }
            }
        }
        
        return try localNewsService.fetchWeekNews()
    }
    
    private func formatDateKey(_ date: Date) -> String {
        return date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }
    
    private func scheduleArrivalNotification(for user: UserProfile) {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Briefing is Ready 🗞️"
        
        let subjectName = user.newsPreferences.subjects.first?.rawValue ?? "world news"
        content.body = "Read your \(user.newsPreferences.duration.rawValue) summary about \(subjectName)."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = user.newsPreferences.arriveTime
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "daily_news_delivery", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Notification scheduled for \(user.newsPreferences.arriveTime):00")
            }
        }
    }
}
