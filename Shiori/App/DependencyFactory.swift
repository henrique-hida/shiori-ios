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

    private let authService: AuthServiceProtocol
    private let userSource: UserSourceProtocol
    private let localNewsSource: LocalNewsSourceProtocol
    private let networkNewsSource: NetworkNewsSourceProtocol
    private let linkSummaryService: LinkSummaryServiceProtocol
    private let linkSummarySource: LinkSummarySourceProtocol
    private let readingHistoryRepo: ReadingHistoryRepositoryProtocol
    private let readLaterRepo: ReadLaterRepositoryProtocol
    private let subjectStatsRepo: SubjectStatsRepositoryProtocol
    private let audioService: AudioServiceProtocol
    
    private init() {
        let dbContext = DatabaseProvider.shared.container.mainContext
        
        self.authService = FirebaseAuthService()
        self.userSource = FirestoreUserSource()
        self.localNewsSource = LocalNewsSource(context: dbContext)
        self.networkNewsSource = FirestoreNewsSource()
        self.linkSummaryService = GeminiLinkSummaryService(apiKey: Bundle.main.geminiApiKey)
        self.linkSummarySource = FirestoreLinkSummarySource()
        self.readingHistoryRepo = ReadingHistoryRepository(modelContext: dbContext)
        self.readLaterRepo = ReadLaterRepository(modelContext: dbContext)
        self.subjectStatsRepo = SubjectStatsRepository(modelContext: dbContext)
        self.audioService = AVFAudioService() // UnrealAudioService(apiKey: Bundle.main.unrealApiKey)
    }
    
    func makeSessionManager() -> SessionManager {
        return SessionManager(
            authService: authService,
            userSource: userSource
        )
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authService: authService)
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(
            authService: authService,
            userSource: userSource
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            syncRepo: makeNewsSyncRepository(),
            linkSummaryService: linkSummaryService,
            linkSummarySource: linkSummarySource,
            networkNewsService: networkNewsSource,
            readingHistoryRepo: readingHistoryRepo,
            readLaterRepo: readLaterRepo,
            subjectStatsRepo: subjectStatsRepo
        )
    }
    
    func makeSettingsViewModel(user: UserProfile, sessionManager: SessionManager) -> SettingsViewModel {
        return SettingsViewModel(
            user: user,
            userSource: userSource,
            sessionManager: sessionManager
        )
    }
    
    func makeAudioPlayerViewModel() -> AudioPlayerViewModel {
        AudioPlayerViewModel(
            audioService: audioService,
            readLaterRepo: readLaterRepo
        )
    }
    
    func makeNewsSyncRepository() -> NewsSyncRepository {
        NewsSyncRepository(
            localNewsService: localNewsSource,
            networkNewsService: networkNewsSource
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
