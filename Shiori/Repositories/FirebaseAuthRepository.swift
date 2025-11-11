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
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthDataResult(user: authDataResult.user)
        } catch {
            throw mapError(error)
        }
    }
    
    func signIn(withEmail email: String, withPassword password: String) async throws -> AuthDataResult {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return AuthDataResult(user: authDataResult.user)
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
