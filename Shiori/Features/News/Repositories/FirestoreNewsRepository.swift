//
//  FirestoreNewsRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import FirebaseFirestore

class FirestoreNewsRepository: CloudNewsRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func getLanguageCode(from language: Language) -> String {
        switch language {
        case .portuguese: return "por"
        case .spanish: return "spa"
        default: return "eng"
        }
    }
    
    func getTodayNews(preferences: NewsPreferences) async throws -> [News] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        let todayStr = formatter.string(from: Date())
        let langKey = getLanguageCode(from: preferences.language)
    
        return try await withThrowingTaskGroup(of: News?.self) { group in
            for subject in preferences.subjects {
                group.addTask {
                    return try await self.fetchSubject(
                        dateStr: todayStr,
                        subject: subject,
                        lang: langKey,
                        style: preferences.style.rawValue,
                        duration: preferences.duration.rawValue
                    )
                }
            }
            
            var results: [News] = []
            for try await article in group {
                if let article = article {
                    results.append(article)
                }
            }
            return results
        }
    }
    
    private func fetchSubject(dateStr: String, subject: NewsSubject, lang: String, style: String, duration: String) async throws -> News? {
        let subjectID = subject.firestoreID
        
        let docRef = db.collection("daily_news")
                       .document(dateStr)
                       .collection("subjects")
                       .document(subjectID)
        
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data(),
              let category = data["category"] as? String,
              let contentMap = data["content"] as? [String: Any],
              let langMap = contentMap[lang] as? [String: Any],
              let styleMap = langMap[style] as? [String: Any],
              let finalContent = styleMap[duration] as? String else {
            
            print("⚠️ Content not found for \(subjectID) | Lang: \(lang) | Style: \(style)")
            return nil
        }
        
        return News(
            id: "\(dateStr)-\(subjectID)",
            category: category,
            content: finalContent,
            date: Date(),
            tone: style,
            wasRead: false
        )
    }
}
