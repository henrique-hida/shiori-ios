//
//  NewsSubjects.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

enum NewsSubject: String, Codable, Sendable, CaseIterable {
    case politic = "Politics"
    case economyAndBusiness = "Economy & Business"
    case technology = "Technology"
    case healthAndScience = "Health & Science"
    case sports = "Sports"
    case entertainmentAndCulture = "Entertainment & Culture"
    
    var firestoreID: String {
        return self.rawValue.lowercased()
            .replacingOccurrences(of: " & ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }

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
