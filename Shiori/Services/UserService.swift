//
//  UserService.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation

protocol UserService {
    var currentUser: LocalUser? { get }
    
    func signUp(withEmail email: String, withPassword password: String, withName firstName: String) async throws
    func signIn(withEmail email: String, withPassword password: String) async throws
    func signOut() throws
    
    init(authRepository: AuthRepository)
}
