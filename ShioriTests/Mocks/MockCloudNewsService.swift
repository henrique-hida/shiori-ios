//
//  MockCloudNewsService.swift
//  ShioriTests
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation
@testable import Shiori

struct MockCloudNewsService: NetworkNewsSourceProtocol {
    func getNews(for date: Date, preferences: Shiori.NewsSummaryPreferences) async throws -> Shiori.Summary {
        
    }
    
    func getPreviousNewsBatch(from startDate: Date, count: Int, preferences: Shiori.NewsSummaryPreferences) async throws -> [Shiori.Summary] {
        
    }
}
