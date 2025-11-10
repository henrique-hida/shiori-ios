//
//  UserRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftUI
import SwiftData

final class DefaultUserService: UserService {
    @Environment(\.modelContext) var context
    @Query private var users: [LocalUser]
    
    let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    var currentUser: LocalUser?
    
    func signUp(withEmail email: String, withPassword password: String, withName firstName: String) async throws {
        let authResult = try await authRepository.signUp(withEmail: email, withPassword: password)
        
        let currentUser = LocalUser(id: authResult.uid, firstName: firstName, isPremium: false, systemLanguage: getUserSystemLanguage(), isDarkSchemePrefered: getUserDarkSchemePrefered(), todayBackupNews: getTodayCustomNews(), newsPreferences: initializeNewsPreferences())
        
        context.insert(currentUser)
        self.currentUser = currentUser
    }
    
    private func initializeNewsPreferences() -> NewsPreferences {
        return NewsPreferences(newsDuration: .standard, newsStyles: .informal, newsSubjects: [.entertainmentAndCulture, .world], newsLanguages: getUserSystemLanguage(), newsArriveTime: 9)
    }
    
    private func getUserSystemLanguage() -> Languages {
        switch(Locale.preferredLanguages.first){
        case "eng":
            return .english
        case "por":
            return .spanish
        case "spa":
            return .spanish
        default:
            return .english
        }
    }
    
    private func getUserDarkSchemePrefered() -> Bool {
        @Environment(\.colorScheme) var colorScheme
        switch(colorScheme){
        case .dark:
            return true
        default:
            return false
        }
    }
    
    private func getTodayCustomNews() -> News {
        return News(title: "Breaking News", content: "Some news have arrived", thumbLink: "https://s2-g1.glbimg.com/uJsrU86-jcyZTdZB4T_fDbE6X2g=/0x69:2362x1398/1080x608/smart/filters:max_age(3600)/https://i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2021/P/4/ptF4I2TCOrbiXeVlpPqw/assets-fotos-790-dandara-mariana-paolla-oliveira-e-rodrigo-simas-falam-sobre-a-final-da-super-danca-1-7acd0cc6ae87.jpg", date: Date(), articleLinks: ["https://g1.globo.com/educacao/enem/2025/noticia/2025/11/09/tema-da-redacao-enem-2025-veja-analise-comentarios-dos-professores.ghtml"], wasRead: false)
    }
    
    func signIn(withEmail email: String, withPassword password: String) async throws {
        let authResult = try await authRepository.signIn(withEmail: email, withPassword: password)
        
        for user in users {
            if user.id == authResult.uid {
                self.currentUser = user
            }
        }
    }
    
    func signOut() throws {
        try authRepository.signOut()
        currentUser = nil
    }
}
