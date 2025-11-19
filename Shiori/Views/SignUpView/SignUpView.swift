//
//  SignUpView.swift
//  Shiori
//
//  Created by Henrique Hida on 18/11/25.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let container: ModelContainer = {
        let schema = Schema([AppUser.self, NewsPreferences.self, NewsPreferences.self, Summary.self])
        return try! ModelContainer(for: schema)
    }()
    SignUpView(userService: DefaultUserService(authRepository: FirebaseAuthRepository(), newsDatabaseRepository: MockNewsDatabaseRepository(), modelContext: container.mainContext))
}
