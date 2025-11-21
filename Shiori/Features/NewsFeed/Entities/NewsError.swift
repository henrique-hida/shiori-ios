//
//  NewsError.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

import Foundation

enum NewsError: Error, LocalizedError {
    case fetchFailed
    case invalidCategory
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Could not load the latest news."
        case .invalidCategory:
            return "The selected category is unavailable."
        case .parsingError:
            return "Failed to process news data."
        }
    }
}
