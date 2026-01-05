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
        return SessionManager(authRepo: authRepo, userRepo: userRepo)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authRepo: authRepo)
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(authRepo: authRepo, userRepo: userRepo)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        let service = makeNewsSyncService()
        return HomeViewModel(syncService: service)
    }
    
    func makeNewsSyncService() -> NewsSyncService {
        let cloudRepo = FirestoreNewsRepository()
        return NewsSyncService(
            localRepo: localNewsRepo,
            cloudRepo: cloudRepo
        )
    }
}
