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
    private let cloudNewsRepo: CloudNewsRepositoryProtocol
    private let linkSummaryRepo: LinkSummaryRepositoryProtocol
    private let cloudLinkPersistenceRepo: LinkSummaryPersistenceProtocol
    private let historyRepo: ReadingHistoryRepositoryProtocol
    private let readLaterRepo: ReadLaterRepositoryProtocol
    private let statsRepo: SubjectStatsRepositoryProtocol
    private let audioService: AudioServiceProtocol
    
    private init() {
        let dbContext = DatabaseProvider.shared.container.mainContext
        
        self.authRepo = FirebaseAuthRepository()
        self.userRepo = FirestoreUserRepository()
        self.localNewsRepo = LocalNewsRepository(context: dbContext)
        self.cloudNewsRepo = FirestoreNewsRepository()
        self.linkSummaryRepo = GeminiLinkSummaryRepository(apiKey: Bundle.main.geminiApiKey)
        self.cloudLinkPersistenceRepo = FirestoreLinkSummaryRepository()
        self.historyRepo = ReadingHistoryRepository(modelContext: dbContext)
        self.readLaterRepo = ReadLaterRepository(modelContext: dbContext)
        self.statsRepo = SubjectStatsRepository(modelContext: dbContext)
        self.audioService = AVFAudioService() // UnrealAudioService(apiKey: Bundle.main.unrealApiKey)
    }
    
    func makeSessionManager() -> SessionManager {
        return SessionManager(
            authRepo: authRepo,
            userRepo: userRepo
        )
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authRepo: authRepo)
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(
            authRepo: authRepo,
            userRepo: userRepo
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            syncService: makeNewsSyncService(),
            linkSummaryRepo: linkSummaryRepo,
            cloudLinkPersistence: cloudLinkPersistenceRepo,
            cloudNewsRepo: cloudNewsRepo,
            historyRepo: historyRepo,
            readLaterRepo: readLaterRepo,
            statsRepo: statsRepo
        )
    }
    
    func makeSettingsViewModel(user: UserProfile, sessionManager: SessionManager) -> SettingsViewModel {
        return SettingsViewModel(
            user: user,
            repository: userRepo,
            sessionManager: sessionManager
        )
    }
    
    func makeAudioPlayerViewModel() -> AudioPlayerViewModel {
        AudioPlayerViewModel(
            audioService: audioService,
            readLaterRepo: readLaterRepo
        )
    }
    
    func makeNewsSyncService() -> NewsSyncService {
        NewsSyncService(
            localRepo: localNewsRepo,
            cloudRepo: cloudNewsRepo
        )
    }
}

extension Bundle {
    var geminiApiKey: String {
        return object(forInfoDictionaryKey: "GeminiAPIKey") as? String ?? ""
    }
    var unrealApiKey: String {
        return object(forInfoDictionaryKey: "UnrealApiKey") as? String ?? ""
    }
}
