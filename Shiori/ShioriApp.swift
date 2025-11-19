//
//  ShioriApp.swift
//  Shiori
//
//  Created by Henrique Hida on 07/11/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct ShioriApp: App {
    
    private let container: ModelContainer = {
        let schema = Schema([AppUser.self, NewsPreferences.self, NewsPreferences.self, Summary.self])
            return try! ModelContainer(for: schema)
        }()
    private let userService: UserService
    
    init() {
        FirebaseApp.configure()
        let modelContent = container.mainContext
        let authRepository: AuthRepository = FirebaseAuthRepository()
        let newsDataBaseRepository: NewsDatabaseRepository = MockNewsDatabaseRepository()
        self.userService = DefaultUserService(
            authRepository: authRepository,
            newsDatabaseRepository: newsDataBaseRepository,
            modelContext: modelContent
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
//              HomeView(userService: userService)
                StartingView(userService: userService)
            }
        }
        .modelContainer(container)
    }
}
