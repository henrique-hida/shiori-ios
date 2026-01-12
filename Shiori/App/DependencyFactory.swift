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
    private let historyRepo: ReadingHistoryRepositoryProtocol
    private let readLaterRepo: ReadLaterRepositoryProtocol
    private let statsRepo: SubjectStatsRepositoryProtocol
    
    private init() {
        let dbContext = DatabaseProvider.shared.container.mainContext
        
        self.authRepo = FirebaseAuthRepository()
        self.userRepo = FirestoreUserRepository()
        self.localNewsRepo = LocalNewsRepository(context: dbContext)
        self.historyRepo = ReadingHistoryRepository(modelContext: dbContext)
        self.readLaterRepo = ReadLaterRepository(modelContext: dbContext)
        self.statsRepo = SubjectStatsRepository(modelContext: dbContext)
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
        let linkSummaryRepo = GeminiLinkSummaryRepository(apiKey: Bundle.main.geminiApiKey)
        return HomeViewModel(
            syncService: service,
            linkSummaryRepo: linkSummaryRepo,
            historyRepo: historyRepo,
            readLaterRepo: readLaterRepo,
            statsRepo: statsRepo
        )
    }
    
    func makeArticlesViewModel() -> ArticlesViewModel {
        return ArticlesViewModel(readLaterRepo: readLaterRepo)
    }
    
    func makeNewsSyncService() -> NewsSyncService {
        let cloudRepo = FirestoreNewsRepository()
        return NewsSyncService(
            localRepo: localNewsRepo,
            cloudRepo: cloudRepo
        )
    }
}

extension Bundle {
    var geminiApiKey: String {
        return object(forInfoDictionaryKey: "GeminiAPIKey") as? String ?? ""
    }
}
