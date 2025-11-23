//
//  SignUpUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignUpUseCase {
    let authRepo: AuthRepositoryProtocol
    let userRepo: UserRepositoryProtocol
    
    func execute(request: SignUpRequest) async throws -> UserProfile {
        let authId = try await authRepo.signUp(email: request.email, password: request.password)
        let newUserProfile = UserProfile(
            id: authId,
            firstName: request.firstName,
            isPremium: false,
            language: request.language,
            theme: .system,
            weekStreak: [false, false, false, false, false, false, false],
            newsPreferences: NewsPreferences(
                duration: request.newsDuration,
                style: request.newsStyle,
                subjects: request.newsSubjects,
                language: request.language,
                arriveTime: request.newsArriveTime
            )
        )
        do {
            try await userRepo.save(newUserProfile)
            return newUserProfile
        } catch {
            print("❌ Save Profile failed. Rolling back Auth...")
            try? await authRepo.deleteCurrentUser()
            throw error
        }
    }
}
