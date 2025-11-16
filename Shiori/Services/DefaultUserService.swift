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
    let authRepository: AuthRepository
    let newsDatabaseRepository: NewsDatabaseRepository
    let modelContext: ModelContext
    
    init(authRepository: AuthRepository, newsDatabaseRepository: NewsDatabaseRepository ,modelContext: ModelContext) {
        self.authRepository = authRepository
        self.newsDatabaseRepository = newsDatabaseRepository
        self.modelContext = modelContext
    }
    
    func signUp(request: SignUpRequest) async throws {
        let authId = try await authNewUser(request: request)
        let newUser = try await createUser(request: request, id: authId)
        try await saveUser(user: newUser)
    }
    
    private func authNewUser(request: SignUpRequest) async throws -> String {
        do {
            return try await authRepository.signUp(email: request.email, password: request.password)
        } catch let authError as AuthError{
            throw UserServiceError.authFailed(authError)
        } catch {
            throw UserServiceError.unknown(error)
        }
    }
    
    private func createUser(request: SignUpRequest, id: String) async throws -> AppUser {
        do {
            return try await convertRequestToUser(request: request, id: id)
        } catch {
            throw UserServiceError.unknown(error)
        }
    }
    
    private func convertRequestToUser(request: SignUpRequest, id: String) async throws -> AppUser {
        let newsPreferences = NewsPreferences(newsDuration: request.newsDuration, newsStyle: request.newsStyle, newsSubjects: request.newsSubjects, newsLanguage: request.language, newsArriveTime: request.newsArriveTime)
        let todayBackupNews = try await newsDatabaseRepository.getTodayNews(newsPreferences: convertNewsPreferencesToRequest(newsPreferences: newsPreferences))
        return AppUser(id: id, firstName: request.firstName, isPremium: request.isPremium, language: request.language, schema: request.schema, todayBackupNews: convertRequestToNews(request: todayBackupNews), newsPreferences: newsPreferences)
    }
    
    private func convertNewsPreferencesToRequest(newsPreferences: NewsPreferences) -> NewsRequest {
        return NewsRequest(newsDuration: newsPreferences.newsDuration, newsStyle: newsPreferences.newsStyle, newsSubjects: newsPreferences.newsSubjects, newsLanguage: newsPreferences.newsLanguage, newsArriveTime: newsPreferences.newsArriveTime)
    }
    
    private func convertRequestToNews(request: NewsRequest) -> News {
        return News(title: request.title!, content: request.content!, thumbLink: request.thumbLink!, date: request.date!, articleLinks: request.articleLinks!, wasRead: request.wasRead!)
    }
    
    private func saveUser(user: AppUser) async throws {
        do {
            modelContext.insert(user)
            try modelContext.save()
        } catch {
            print("SwiftData save failed. Rolling back Firebase user...")
            try? await authRepository.deleteCurrentUser()
            throw UserServiceError.userDatabaseSaveFailed(error)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await authRepository.signIn(email: email, password: password)
        } catch let authError as AuthError {
            throw UserServiceError.authFailed(authError)
        } catch {
            throw UserServiceError.unknown(error)
        }
    }
    
    func signOut() throws {
        do {
            try authRepository.signOut()
        } catch let authError as AuthError {
            throw UserServiceError.authFailed(authError)
        } catch {
            throw UserServiceError.unknown(error)
        }
    }
}
