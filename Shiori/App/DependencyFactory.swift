//
//  DependencyFactory.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftData

@MainActor
final class DependencyFactory {
    static let shared = DependencyFactory()

    private let authRepo: AuthRepository
    private let userRepo: UserPersistence
    private let newsRepo: NewsDatabaseRepository
    
    private init() {
        let dbContext = DatabaseProvider.shared.container.mainContext
        self.authRepo = FirebaseAuthRepository()
        self.userRepo = SwiftDataUserRepository(context: dbContext)
        self.newsRepo = MockNewsDatabaseRepository()
    }
    
    func makeSessionManager() -> SessionManager {
        let useCase = ObserveSessionUseCase(
            authRepo: authRepo,
            userRepo: userRepo
        )
        return SessionManager(observeSession: useCase)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        let useCase = SignInUseCase(authRepo: authRepo)
        return SignInViewModel(signIn: useCase)
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        let useCase = SignUpUseCase(
            authRepo: authRepo,
            newsRepo: newsRepo,
            userRepo: userRepo
        )
        return SignUpViewModel(signUp: useCase)
    }
}
