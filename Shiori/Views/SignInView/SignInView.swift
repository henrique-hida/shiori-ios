//
//  SignInView.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import SwiftUI
import SwiftData

struct SignInView: View {
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
    SignInView(userService: DefaultUserService(authRepository: FirebaseAuthRepository(), newsDatabaseRepository: MockNewsDatabaseRepository(), modelContext: container.mainContext))
}
