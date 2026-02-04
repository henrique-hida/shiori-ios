//
//  AuthRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
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
