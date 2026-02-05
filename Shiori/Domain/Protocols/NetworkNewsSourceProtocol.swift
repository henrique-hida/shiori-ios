//
//  CloudNewsServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol NetworkNewsSourceProtocol {
    func getNews(for date: Date, preferences: NewsSummaryPreferences) async throws -> Summary
    func getPreviousNewsBatch(from startDate: Date, count: Int, preferences: NewsSummaryPreferences) async throws -> [Summary]
}
