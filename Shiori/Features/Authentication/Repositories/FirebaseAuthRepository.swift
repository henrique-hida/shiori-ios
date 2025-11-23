//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import Combine
import FirebaseAuth

struct AuthDataResult {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class FirebaseAuthRepository: AuthRepositoryProtocol {
    private let authStateSubject = CurrentValueSubject<String?, Never>(Auth.auth().currentUser?.uid)
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateHandler()
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func registerAuthStateHandler() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user?.uid)
        }
    }
    
    var authStatePublisher: AnyPublisher<String?, Never> {
        return authStateSubject.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
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
