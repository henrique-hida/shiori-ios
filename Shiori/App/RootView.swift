//
//  RootView.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import SwiftUI

struct RootView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        Group {
            switch sessionManager.state {
            case .checking:
                ProgressView()
            case .unauthenticated:
                NavigationStack {
                    StartingView()
                }
            case .authenticated(let userProfile):
                NavigationStack {
                    HomeView(user: userProfile)
                }
            }
        }
        .animation(.easeInOut, value: sessionManager.state)
    }
}
