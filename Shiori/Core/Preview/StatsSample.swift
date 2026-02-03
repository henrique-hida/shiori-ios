//
//  StatsSample.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import Foundation

extension SubjectStatsData {
    static let currentYear = Calendar.current.component(.year, from: Date())
    
    static var sampleStats: [SubjectStatsData] = {
        let tech = SubjectStatsData(year: currentYear, subject: .technology)
        tech.count = 15
        
        let health = SubjectStatsData(year: currentYear, subject: .healthAndScience)
        health.count = 8
        
        let politic = SubjectStatsData(year: currentYear, subject: .politic)
        politic.count = 5
        
        let economy = SubjectStatsData(year: currentYear, subject: .economyAndBusiness)
        economy.count = 12
        
        return [tech, health, politic, economy]
    }()
}
