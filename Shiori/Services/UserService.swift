//
//  UserService.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation
import SwiftData

struct SignUpRequest: Sendable {
    let email: String
    let password: String
    let firstName: String
    let isPremium: Bool
    let language: Language
    let schema: Schema
    
    let newsDuration: NewsDuration
    let newsStyle: NewsStyle
    let newsSubjects: [NewsSubject]
    let newsArriveTime: Int
}

protocol UserService {
    func signUp(request: SignUpRequest) async throws -> String
    func signIn(email: String, password: String) async throws -> String
    func signOut() throws
    
    init(authRepository: AuthRepository, newsDatabaseRepository: NewsDatabaseRepository, modelContext: ModelContext)
}
