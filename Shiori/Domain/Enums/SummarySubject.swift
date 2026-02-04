//
//  SummarySubject.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

enum SummarySubject: String, Codable, Sendable, CaseIterable {
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
    
    var shortName: String {
        switch self {
        case .politic: return "politics"
        case .economyAndBusiness: return "economy"
        case .technology: return "tech"
        case .healthAndScience: return "science"
        case .sports: return "sports"
        case .entertainmentAndCulture: return "entertainment"
        }
    }
}
