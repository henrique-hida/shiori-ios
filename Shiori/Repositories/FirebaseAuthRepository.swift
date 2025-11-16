//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import FirebaseAuth

struct AuthDataResult {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class FirebaseAuthRepository: AuthRepository {
    func signUp(email: String, password: String) async throws -> String {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthDataResult(user: authDataResult.user).uid
        } catch {
            throw mapError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw mapError(error)
        }
    }
    
    func signOut() throws{
        do {
            try Auth.auth().signOut()
        } catch {
            throw mapError(error)
        }
    }
    
    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }
        do {
            try await user.delete()
        } catch {
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard let errCode = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }
        
        switch errCode {
        case .wrongPassword, .userNotFound, .invalidCredential:
            return .invalidCredentials
        case .invalidEmail:
            return .invalidEmailFormat
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknown
        }
    }
}
