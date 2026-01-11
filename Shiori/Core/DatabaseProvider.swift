//
//  DatabaseProvider.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftData

final class DatabaseProvider: Sendable {
    static let shared = DatabaseProvider()
    let container: ModelContainer
    
    init(inMemory: Bool = false) {
        let schema = Schema([
            SummaryData.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    static let preview: DatabaseProvider = {
        let provider = DatabaseProvider(inMemory: true)
        return provider
    }()
}
