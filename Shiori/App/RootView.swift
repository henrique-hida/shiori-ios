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
                StartingView()
            case .authenticated(let user):
                HomeView(user: user)
            }
        }
    }
}
