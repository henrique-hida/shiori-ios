//
//  ReadingHistoryServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol ReadingHistoryRepositoryProtocol {
    func getHistory(for weekDates: [Date]) async throws -> Set<String>
    func markTodayAsRead(user: UserProfile) async throws
}
