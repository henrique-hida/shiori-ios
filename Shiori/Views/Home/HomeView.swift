//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI

struct HomeView: View {
    let userService: UserService
    @State private var viewModel: HomeViewModel
    
    init(userService: UserService) {
        self.userService = userService
        self.viewModel = HomeViewModel(userService: userService)
    }
        
    var body: some View {
        NavigationStack {
            switch viewModel.state {
            case .userLoggedIn:
                Text("Home View")
            case .userLoggedOut:
                SignInView()
            }
        }
    }
}

#Preview {
    let userService: UserService
    let authRepository: AuthRepository
    HomeView(userService: DefaultUserService(authRepository: FirebaseAuthRepository()))
}
