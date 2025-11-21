//
//  NewsDurations.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

enum NewsDuration: String, Codable, Sendable, CaseIterable {
    case fast = "fast"
    case standard = "standard"
    case deep = "deep"
}
