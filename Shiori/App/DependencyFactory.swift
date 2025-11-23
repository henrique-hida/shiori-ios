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

    private let authRepo: AuthRepositoryProtocol
    private let userRepo: UserRepositoryProtocol
    private let localNewsRepo: LocalNewsRepositoryProtocol
    
    private init() {
        let dbContext = DatabaseProvider.shared.container.mainContext
        
        self.authRepo = FirebaseAuthRepository()
        self.userRepo = FirestoreUserRepository()
        self.localNewsRepo = LocalNewsRepository(context: dbContext)
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
            userRepo: userRepo
        )
        return SignUpViewModel(signUp: useCase)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        let cloudRepo = FirestoreNewsRepository()
        return HomeViewModel(
            localRepo: localNewsRepo,
            cloudRepo: cloudRepo
        )
    }
}
