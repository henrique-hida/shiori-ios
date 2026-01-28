//
//  NewsPreferences.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation

struct NewsSummaryPreferences: Codable, Equatable {
    var duration: SummaryDuration
    var style: SummaryStyle
    var subjects: [SummarySubject]
    var language: Language
    var arriveTime: Int
}

enum SummaryDuration: String, Codable, CaseIterable {
    case fast = "fast"
    case standard = "standard"
    case deep = "deep"
}

enum SummaryStyle: String, Codable, CaseIterable {
    case impartial = "impartial"
    case informal = "informal"
    case analytic = "analytic"
    case funny = "funny"
}

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
}
