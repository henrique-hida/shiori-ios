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
    @State private var sessionManager: SessionManager
    
    init() {
        FirebaseApp.configure()
        
        let manager = DependencyFactory.shared.makeSessionManager()
        _sessionManager = State(initialValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .environment(sessionManager)
            }
        }
        .modelContainer(DatabaseProvider.shared.container)
    }
}
