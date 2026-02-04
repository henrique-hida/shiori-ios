//
//  ValidationError.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

enum ValidationError: Error, LocalizedError, Equatable {
    case emptyField(String)
    case invalidNameFormat
    case invalidEmailFormat
    case passwordTooShort
    case passwordTooLong
    
    var affectedField: String? {
        switch self {
        case .invalidNameFormat:
            return "first name"
        case .invalidEmailFormat:
            return "email"
        case .passwordTooShort, .passwordTooLong:
            return "password"
        case .emptyField(let field):
            return field
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "Please fill the \(fieldName) field."
        case .invalidNameFormat:
            return "The first name is badly formatted."
        case .invalidEmailFormat:
            return "The email address is badly formatted."
        case .passwordTooShort:
            return "Password must be at least 10 characters."
        case .passwordTooLong:
            return "Password is too long."
        }
    }
}
