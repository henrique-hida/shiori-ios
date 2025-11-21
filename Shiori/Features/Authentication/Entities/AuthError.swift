//
//  AuthError.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidEmailFormat
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case databaseSaveFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .invalidEmailFormat:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "This email address is already in use."
        case .weakPassword:
            return "The password must be at least 6 characters long."
        case .networkError:
            return "A network error occurred. Please check your connection."
        case .databaseSaveFailed:
            return "A internal error occured. Please try again later."
        case .unknown:
            return "An unknown error occurred. Please try again later."
        }
    }
}
