//
//  SignInUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignInUseCase {
    let authRepo: AuthRepository
    
    func execute(email: String, password: String) async throws {
        try await authRepo.signIn(email: email, password: password)
    }
}
