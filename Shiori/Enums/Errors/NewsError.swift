//
//  NewsError.swift
//  Shiori
//
//  Created by Henrique Hida on 11/11/25.
//

import Foundation

enum NewsError: Error, LocalizedError {
    case error
    
    var errorDescription: String? {
        switch self {
        case .error:
            return "erro"
        }
    }
}
