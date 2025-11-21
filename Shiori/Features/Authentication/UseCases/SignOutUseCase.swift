//
//  SignOutUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignOutUseCase {
    let authRepo: AuthRepository
    
    func execute() throws {
        try authRepo.signOut()
    }
}
