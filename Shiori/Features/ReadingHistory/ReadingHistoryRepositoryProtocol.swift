//
//  ReadingHistoryRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
import SwiftData
import FirebaseFirestore

protocol ReadingHistoryRepositoryProtocol {
    func getHistory(for weekDates: [Date]) async throws -> Set<String>
    func markTodayAsRead(user: UserProfile) async throws
}
