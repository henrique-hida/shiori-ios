//
//  UserServiceError.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

enum UserServiceError: Error, LocalizedError {
    case authFailed(AuthError)
    case userDatabaseSaveFailed(Error)
    case newsDatabaseFailed(NewsError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .authFailed(let authError):
            return authError.errorDescription
        case .userDatabaseSaveFailed:
            return "Your account was created, but we couldn't save your profile. Please try logging in."
        case .newsDatabaseFailed(let newsError):
            return newsError.errorDescription
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
