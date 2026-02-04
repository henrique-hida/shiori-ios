//
//  ReadingHistoryRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
import SwiftData
import FirebaseFirestore

final class ReadingHistoryRepository: ReadingHistoryRepositoryProtocol {
    private let modelContext: ModelContext
    private let db = Firestore.firestore()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    private func getDayID(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getHistory(for weekDates: [Date]) async throws -> Set<String> {
        let ids = weekDates.map { getDayID(from: $0) }
        var foundIds = Set<String>()
        
        let descriptor = FetchDescriptor<ReadingHistoryData>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        
        let localResults = try? modelContext.fetch(descriptor)
        localResults?.forEach { foundIds.insert($0.id) }
        
        return foundIds
    }
    
    func markTodayAsRead(user: UserProfile) async throws {
        let today = Date()
        let id = getDayID(from: today)
        
        let descriptor = FetchDescriptor<ReadingHistoryData>(predicate: #Predicate { $0.id == id })
        let count = try? modelContext.fetchCount(descriptor)
        
        if count == 0 {
            let entry = ReadingHistoryData(date: today)
            modelContext.insert(entry)
            try? modelContext.save()
        }
        
        guard let userId = user.id else { return }
        let docRef = db.collection("users").document(userId).collection("reading_history").document(id)
        
        try await docRef.setData([
            "date": Timestamp(date: today),
            "id": id
        ], merge: true)
    }
}
