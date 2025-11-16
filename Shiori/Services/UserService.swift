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
    let schema: Theme
    
    let newsDuration: NewsDuration
    let newsStyle: NewsStyle
    let newsSubjects: [NewsSubject]
    let newsArriveTime: Int
}

protocol UserService {
    var authRepository: AuthRepository { get }
    var newsDatabaseRepository: NewsDatabaseRepository { get }
    var modelContext: ModelContext { get }
    
    init(authRepository: AuthRepository, newsDatabaseRepository: NewsDatabaseRepository, modelContext: ModelContext)
    
    func signUp(request: SignUpRequest) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}
