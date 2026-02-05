//
//  MockHistoryService.swift
//  ShioriTests
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
@testable import Shiori

struct MockHistoryService: ReadingHistoryRepositoryProtocol {
    func getHistory(for weekDates: [Date]) async throws -> Set<String> {
        [""]
    }
    
    func markTodayAsRead(user: Shiori.UserProfile) async throws {
        
    }
    
    
}

