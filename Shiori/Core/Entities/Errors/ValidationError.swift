//
//  ValidationError.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

enum ValidationError: Error, LocalizedError, Equatable {
    case emptyField(String)
    case invalidEmailFormat
    case passwordTooShort
    case passwordTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "Please fill the \(fieldName) field."
        case .invalidEmailFormat:
            return "The email address is badly formatted."
        case .passwordTooShort:
            return "Password must be at least 6 characters."
        case .passwordTooLong:
            return "Password is too long."
        }
    }
}
