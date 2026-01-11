//
//  AuthService.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import Combine

protocol AuthRepositoryProtocol {
    var authStatePublisher: AnyPublisher<String?, Never> { get }
    
    func signUp(_ email: String, _ password: String) async throws -> String
    func signIn(_ email: String, _ password: String) async throws
    func signOut() throws
    func deleteCurrentUser() async throws
}
