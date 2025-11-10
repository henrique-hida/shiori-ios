//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthRepository: AuthRepository {
    func signUp(withEmail email: String, withPassword password: String) async throws -> AuthDataResult {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResult(user: authDataResult.user)
    }
    
    func signIn(withEmail email: String, withPassword password: String) async throws -> AuthDataResult {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResult(user: authDataResult.user)
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
}
