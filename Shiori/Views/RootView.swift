//
//  RootView.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @State private var authViewModel: AuthViewModel
    
    private let userService: UserService
    private let modelContext: ModelContext
    
    init(userService: UserService, modelContext: ModelContext) {
        self.userService = userService
        self.modelContext = modelContext
        
        self._authViewModel = State(wrappedValue: AuthViewModel(
            userService: userService,
            modelContext: modelContext
        ))
    }
    
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .checking:
                ProgressView()
            case .signedOut:
                StartingView(userService: userService)
            case .signedIn:
                HomeView(userService: userService)
            }
        }
        .environment(authViewModel)
        .environment(\.modelContext, modelContext)
    }
}
