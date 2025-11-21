//
//  SignUpUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignUpUseCase {
    let authRepo: AuthRepository
    let newsRepo: NewsDatabaseRepository
    let userRepo: UserPersistence
    
    func execute(request: SignUpRequest) async throws {
        let authId = try await authRepo.signUp(email: request.email, password: request.password)
        
        do {
            let preferences = NewsPreferences(
                newsDuration: request.newsDuration,
                newsStyle: request.newsStyle,
                newsSubjects: request.newsSubjects,
                newsLanguage: request.language,
                newsArriveTime: request.newsArriveTime
            )
            
            let apiRequestDTO: NewsRequestBody = NewsMapper.mapToDTO(from: preferences)
            let newsResponseDTO: NewsResponseDTO = try await newsRepo.getTodayNews(newsPreferences: apiRequestDTO)
            let initialNews = NewsMapper.mapToEntity(from: newsResponseDTO)
            let newUser = UserMapper.map(
                request: request,
                id: authId,
                initialNews: initialNews,
                preferences: preferences
            )
            try await userRepo.save(newUser)
            
        } catch {
            print("Save failed. Rolling back Auth...")
            try? await authRepo.deleteCurrentUser()
            throw error
        }
    }
}
