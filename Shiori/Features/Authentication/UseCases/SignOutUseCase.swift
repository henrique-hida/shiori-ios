//
//  SignOutUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignOutUseCase {
    let authRepo: AuthRepositoryProtocol
    
    func execute() throws {
        try authRepo.signOut()
    }
}
