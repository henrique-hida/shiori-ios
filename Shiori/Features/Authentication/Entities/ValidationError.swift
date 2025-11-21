//
//  ValidationError.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case passwordTooShort
    case passwordTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "Please fill the \(fieldName) field."
        case .passwordTooShort:
            return "Password must be at least 6 characters."
        case .passwordTooLong:
            return "Password is too long."
        }
    }
}
