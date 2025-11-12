//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
        
    var body: some View {
        
    }
}

#Preview {
    let container: ModelContainer = {
        let schema = Schema([AppUser.self, NewsPreferences.self, NewsPreferences.self, Summary.self])
            return try! ModelContainer(for: schema)
        }()
    HomeView(userService: DefaultUserService(authRepository: FirebaseAuthRepository(), newsDatabaseRepository: MockNewsDatabaseRepository(), modelContext: container.mainContext))
}
