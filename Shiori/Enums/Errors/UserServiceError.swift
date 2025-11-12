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
    case shortPassword
    case longPassword
    case emptyPassword
    case emptyEmail
    case emptyFirstName
    case emptyNewsDuration
    case emptyNewsStyle
    case emptySubjects
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .authFailed(let authError):
            return authError.errorDescription
        case .userDatabaseSaveFailed:
            return "Internal error. Please try again later."
        case .newsDatabaseFailed(let newsError):
            return newsError.errorDescription
        case .shortPassword:
            return "Password must not exceed 64 characteres."
        case .longPassword:
            return "Password must have at least 10 characteres."
        case .emptyPassword:
            return "Please fill the password field"
        case .emptyEmail:
            return "Please fill the email field."
        case .emptyFirstName:
            return "Please fill the first name field."
        case .emptyNewsDuration:
            return "Please select a duration."
        case .emptyNewsStyle:
            return "Please select a style."
        case .emptySubjects:
            return "Please select at least one subject."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
