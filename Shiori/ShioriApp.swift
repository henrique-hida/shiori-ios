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
    
    private let authRepository: AuthRepository
    private let userService: UserService
    
    init() {
        FirebaseApp.configure()
        
        self.authRepository = FirebaseAuthRepository()
        self.userService = DefaultUserService(authRepository: authRepository)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(userService: userService)
        }
        .modelContainer(for: [AppUser.self])
    }
}
