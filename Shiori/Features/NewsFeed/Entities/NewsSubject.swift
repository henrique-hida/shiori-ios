//
//  NewsSubjects.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

enum NewsSubject: String, Codable, Sendable, CaseIterable {
    case politic = "politic"
    case economyAndBusiness = "economy"
    case world = "world"
    case technology = "technology"
    case healthAndScience = "health"
    case sports = "sports"
    case entertainmentAndCulture = "entertainment"
}
