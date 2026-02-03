//
//  FirestoreNewsRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import FirebaseFirestore

protocol CloudNewsRepositoryProtocol {
    func getNews(for date: Date, preferences: NewsSummaryPreferences) async throws -> Summary
    func getPreviousNewsBatch(from startDate: Date, count: Int, preferences: NewsSummaryPreferences) async throws -> [Summary]
}

final class FirestoreNewsRepository: CloudNewsRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func getNews(for date: Date, preferences: NewsSummaryPreferences) async throws -> Summary {
        let dateStr = date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
        
        let parts = try await fetchAllSubjects(
            dateStr: dateStr,
            preferences: preferences
        )
        
        guard !parts.isEmpty else {
            throw NSError(domain: "Shiori", code: 404, userInfo: [NSLocalizedDescriptionKey: "No news found for \(dateStr)."])
        }
        
        return createSummary(from: parts, dateStr: dateStr, originalDate: date, preferences: preferences)
    }
    
    private func fetchAllSubjects(dateStr: String, preferences: NewsSummaryPreferences) async throws -> [SubjectPart] {
        return try await withThrowingTaskGroup(of: SubjectPart?.self) { group in
            for subject in preferences.subjects {
                group.addTask {
                    return try await self.fetchSubjectPart(
                        dateStr: dateStr,
                        subject: subject,
                        lang: preferences.language.rawValue,
                        style: preferences.style.rawValue,
                        duration: preferences.duration.rawValue
                    )
                }
            }
            
            var results: [SubjectPart] = []
            for try await part in group {
                if let part = part { results.append(part) }
            }
            
            return results.sorted { p1, p2 in
                let idx1 = preferences.subjects.firstIndex(of: p1.subjectType) ?? Int.max
                let idx2 = preferences.subjects.firstIndex(of: p2.subjectType) ?? Int.max
                return idx1 < idx2
            }
        }
    }
    
    private func fetchSubjectPart(dateStr: String, subject: SummarySubject, lang: String, style: String, duration: String) async throws -> SubjectPart? {
        let docRef = db.collection("news").document(dateStr).collection("subjects").document(subject.firestoreID)
        let snapshot = try await docRef.getDocument()
        
        guard let newsDoc = try? snapshot.data(as: NewsDocumentDTO.self) else {
            print("⚠️ Failed to decode document for \(subject.firestoreID)")
            return nil
        }
        
        guard let langData = newsDoc.content[lang],
              let styleData = langData.styles[style],
              let finalContent = styleData.durations[duration] else {
            print("⚠️ Missing content for \(subject.firestoreID)")
            return nil
        }
        
        return SubjectPart(
            subjectType: subject,
            category: newsDoc.category,
            title: styleData.title,
            content: finalContent,
            thumbUrl: newsDoc.thumbUrl,
            sources: langData.sources
        )
    }
    
    private func createSummary(from parts: [SubjectPart], dateStr: String, originalDate: Date, preferences: NewsSummaryPreferences) -> Summary {
        let aggregatedContent = parts.map { part in
            """
            **\(part.category.uppercased()): \(part.title)**
            \(part.content)
            """
        }.joined(separator: "\n\n")
        
        let allSources = Array(Set(parts.flatMap { $0.sources })).sorted()
        let mainThumbUrl = parts.first { !$0.thumbUrl.isEmpty }?.thumbUrl ?? ""
        
        return Summary(
            id: "daily-\(dateStr)",
            title: "Daily Briefing: \(dateStr)",
            content: aggregatedContent,
            createdAt: originalDate,
            thumbUrl: mainThumbUrl,
            sources: allSources,
            subjects: parts.map { $0.subjectType },
            type: .news
        )
    }
    
    func getPreviousNewsBatch(
        from startDate: Date,
        count: Int,
        preferences: NewsSummaryPreferences
    ) async throws -> [Summary] {
        
        let calendar = Calendar.current
        let datesToFetch = (1...count).compactMap { i in
            calendar.date(byAdding: .day, value: -i, to: startDate)
        }
        
        return await withTaskGroup(of: Summary?.self) { group in
            for date in datesToFetch {
                group.addTask {
                    return try? await self.getNews(for: date, preferences: preferences)
                }
            }
            
            var results: [Summary] = []
            for await summary in group {
                if let summary = summary {
                    results.append(summary)
                }
            }
            
            return results.sorted { $0.createdAt > $1.createdAt }
        }
    }
}

private struct NewsDocumentDTO: Decodable {
    let category: String
    let thumbUrl: String
    let content: [String: LanguageContentDTO]
}

private struct LanguageContentDTO: Decodable {
    let sources: [String]
    let styles: [String: StyleContentDTO]
}

private struct StyleContentDTO: Decodable {
    let title: String
    let durations: [String: String]
}

private struct SubjectPart {
    let subjectType: SummarySubject
    let category: String
    let title: String
    let content: String
    let thumbUrl: String
    let sources: [String]
}
