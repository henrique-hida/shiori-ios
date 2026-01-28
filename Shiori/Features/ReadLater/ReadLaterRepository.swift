//
//  ReadLaterRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
import SwiftData
import FirebaseFirestore

final class ReadLaterRepository: ReadLaterRepositoryProtocol {
    private let modelContext: ModelContext
    private let db = Firestore.firestore()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAll() async -> [ReadLater] {
        let descriptor = FetchDescriptor<ReadLaterData>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        do {
            let results = try modelContext.fetch(descriptor)
            return results.map { ReadLater(from: $0) }
        } catch {
            return []
        }
    }
    
    func isSaved(id: String) -> Bool {
        let descriptor = FetchDescriptor<ReadLaterData>(predicate: #Predicate { $0.id == id })
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }
    
    func save(_ summary: Summary, user: UserProfile) async {
        if !isSaved(id: summary.id) {
            let item = ReadLaterData(summary: summary)
            modelContext.insert(item)
            try? modelContext.save()
            print("💾 Saved to Read Later (Local)")
        }
        
        guard let userId = user.id else { return }
        let docRef = db.collection("users").document(userId).collection("read_later").document(summary.id)
        
        let data: [String: Any] = [
            "id": summary.id,
            "title": summary.title,
            "thumbUrl": summary.thumbUrl,
            "createdAt": Timestamp(date: summary.createdAt),
            "savedAt": FieldValue.serverTimestamp()
        ]
        
        try? await docRef.setData(data, merge: true)
    }
    
    func remove(id: String, user: UserProfile) async {
        let descriptor = FetchDescriptor<ReadLaterData>(predicate: #Predicate { $0.id == id })
        if let results = try? modelContext.fetch(descriptor) {
            for item in results {
                modelContext.delete(item)
            }
            try? modelContext.save()
            print("🗑️ Removed from Read Later (Local)")
        }
        
        guard let userId = user.id else { return }
        try? await db.collection("users").document(userId).collection("read_later").document(id).delete()
    }
}
