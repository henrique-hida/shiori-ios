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
    case technology = "tech"
    case healthAndScience = "health"
    case sports = "sports"
    case entertainmentAndCulture = "entertainment"
}

extension NewsSubject {
    var iconName: String {
        switch self {
        case .politic: return "building.columns"
        case .economyAndBusiness: return "chart.pie"
        case .technology: return "laptopcomputer"
        case .healthAndScience: return "staroflife"
        case .sports: return "sportscourt"
        case .entertainmentAndCulture: return "theatermasks"
        }
    }
}
