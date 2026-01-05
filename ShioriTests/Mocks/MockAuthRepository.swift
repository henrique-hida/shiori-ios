//
//  MockAuthRepository.swift
//  ShioriTests
//
//  Created by Henrique Hida on 03/01/26.
//

import Foundation
import Combine
@testable import Shiori

struct MockAuthRepository: AuthRepositoryProtocol {
    var authStatePublisher: AnyPublisher<String?, Never> = Just(nil).eraseToAnyPublisher()
    
    func signUp(_ email: String, _ password: String) async throws -> String {
        return "success"
    }
    
    func signIn(_ email: String, _ password: String) async throws {
        
    }
    
    func signOut() throws {
        
    }
    
    func deleteCurrentUser() async throws {
        
    }
}
