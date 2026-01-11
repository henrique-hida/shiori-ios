//
//  NewsSyncService.swift
//  Shiori
//
//  Created by Henrique Hida on 16/12/25.
//

import Foundation
import UserNotifications

@MainActor
final class NewsSyncService {
    private let localRepo: LocalNewsRepositoryProtocol
    private let cloudRepo: CloudNewsRepositoryProtocol
    
    init(localRepo: LocalNewsRepositoryProtocol, cloudRepo: CloudNewsRepositoryProtocol) {
        self.localRepo = localRepo
        self.cloudRepo = cloudRepo
    }

    func syncAndLoadWeek(for user: UserProfile, isBackgroundTask: Bool = false) async throws -> [Summary] {
        let today = Date()
        let localToday = try localRepo.fetchNews(forDate: today)
        
        if localToday == nil {
            print("🌍 Today's news missing locally. Fetching from Cloud...")
            do {
                let fetchedSummary = try await cloudRepo.getTodayNews(preferences: user.newsPreferences)
                try await localRepo.saveNews(fetchedSummary)
                print("✅ Cloud fetch successful & saved.")
                if isBackgroundTask {
                    scheduleArrivalNotification(for: user)
                }
            } catch {
                print("⚠️ Cloud fetch failed (Offline or 04:00 GMT issue): \(error)")
            }
        } else {
            print("✅ Today's news is already locally cached.")
        }
        
        return try localRepo.fetchWeekNews()
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
