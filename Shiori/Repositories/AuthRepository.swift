//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

protocol AuthRepository {
    func signUp(email: String, password: String) async throws -> String
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func deleteCurrentUser() async throws
}
