//
//  MockLinkPersistenceService.swift
//  ShioriTests
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation
@testable import Shiori

struct MockLinkPersistenceService: LinkSummarySourceProtocol {
    func saveLinkSummary(_ summary: Shiori.Summary, userId: String) async throws {
        
    }
    
    func fetchLinkSummaries(userId: String) async throws -> [Shiori.Summary] {
        
    }
    
    
}
