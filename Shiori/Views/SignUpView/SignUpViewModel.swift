//
//  SignUpViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation

final class SignUpViewModel {
    private func verifyPassword(password: String) throws -> String {
        if password.isEmpty {
            throw UserServiceError.emptyPassword
        } else if password.count < 10 {
            throw UserServiceError.shortPassword
        } else if password.count > 64 {
            throw UserServiceError.longPassword
        } else {
            return password
        }
    }
}
