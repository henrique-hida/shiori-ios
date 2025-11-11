//
//  UserService.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation

protocol UserService {
    func signUp(withEmail email: String, withPassword password: String, withName firstName: String) async throws -> AppUser
    func signIn(withEmail email: String, withPassword password: String) async throws -> AppUser
    func signOut() throws
    
    init(authRepository: AuthRepository, users: [AppUser])
}
