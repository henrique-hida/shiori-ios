//
//  MockStatsService.swift
//  ShioriTests
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation
@testable import Shiori

struct MockStatsService: SubjectStatsRepositoryProtocol {
    func increment(subjects: [Shiori.SummarySubject]) async {
        
    }
    
    func getYearlyStats(year: Int) async -> [(subject: Shiori.SummarySubject, percentage: Double)] {
        
    }
    
    
}
