//
//  FirestoreLinkSummaryRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 03/02/26.
//

import Foundation
import FirebaseFirestore

protocol LinkSummaryPersistenceProtocol {
    func saveLinkSummary(_ summary: Summary, userId: String) async throws
    func fetchLinkSummaries(userId: String) async throws -> [Summary]
}

final class FirestoreLinkSummaryRepository: LinkSummaryPersistenceProtocol {
    private let db = Firestore.firestore()
    
    func saveLinkSummary(_ summary: Summary, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection("link_summaries").document(summary.id)
        let data = try summary.toFirestoreData()
        try await docRef.setData(data)
    }
    
    func fetchLinkSummaries(userId: String) async throws -> [Summary] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("link_summaries")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? Summary(from: doc.data())
        }
    }
}

private extension Summary {
    func toFirestoreData() throws -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "content": content,
            "createdAt": Timestamp(date: createdAt),
            "thumbUrl": thumbUrl,
            "sources": sources,
            "subjects": subjects.map { $0.rawValue },
            "type": type.rawValue
        ]
    }
    
    init?(from data: [String: Any]) throws {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["createdAt"] as? Timestamp,
              let thumbUrl = data["thumbUrl"] as? String,
              let sources = data["sources"] as? [String],
              let subjectsRaw = data["subjects"] as? [String],
              let typeRaw = data["type"] as? String,
              let type = SummaryType(rawValue: typeRaw)
        else { return nil }
        
        self.init(
            id: id,
            title: title,
            content: content,
            createdAt: timestamp.dateValue(),
            thumbUrl: thumbUrl,
            sources: sources,
            subjects: subjectsRaw.compactMap { SummarySubject(rawValue: $0) },
            type: type
        )
    }
}
