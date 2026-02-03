//
//  FirestoreUserRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import FirebaseFirestore

protocol UserRepositoryProtocol {
    func save(_ user: UserProfile) async throws
    func fetchUser(id: String) async throws -> UserProfile?
}

struct FirestoreUserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func save(_ user: UserProfile) async throws {
        guard let userId = user.id else {
            print("❌ Error: Cannot save user without an ID.")
            return
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try db.collection("users").document(userId).setData(from: user) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func fetchUser(id: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(id).getDocument()
        return try? document.data(as: UserProfile.self)
    }
}
