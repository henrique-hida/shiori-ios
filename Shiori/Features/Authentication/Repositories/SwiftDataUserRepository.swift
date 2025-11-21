//
//  SwiftDataUserRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataUserRepository: UserPersistence {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save(_ user: AppUser) async throws {
        context.insert(user)
        try context.save()
    }
    
    func fetchUser(id: String) async throws -> AppUser? {
        let descriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.id == id }
        )
        let results = try context.fetch(descriptor)
        return results.first
    }
}
