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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [CurrentUser.self])
    }
}
