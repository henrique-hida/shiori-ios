//
//  MockLinkSummaryService.swift
//  Shiori
//
//  Created by Henrique Hida on 03/02/26.
//

import Foundation

final class MockLinkSummarySource: LinkSummarySourceProtocol {
    func saveLinkSummary(_ summary: Summary, userId: String) async throws {
        print("Link summary saved!")
    }
    
    func fetchLinkSummaries(userId: String) async throws -> [Summary] {
        return Summary.sampleSummaries.map{$0.summaryRaw}
    }
}
