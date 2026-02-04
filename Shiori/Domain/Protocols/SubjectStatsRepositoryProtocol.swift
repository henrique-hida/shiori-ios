//
//  SubjectStatsRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol SubjectStatsRepositoryProtocol {
    func increment(subjects: [SummarySubject]) async
    func getYearlyStats(year: Int) async -> [(subject: SummarySubject, percentage: Double)]
}
