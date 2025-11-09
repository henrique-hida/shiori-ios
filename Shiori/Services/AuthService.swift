//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

protocol AuthService {
    var shared: AuthService { get }
    func signUp(withEmail email: String, withPassword password: String) async throws -> AuthDataResult
    func signIn(withEmail email: String, withPassword password: String) async throws -> AuthDataResult
    func signOut() throws
}
