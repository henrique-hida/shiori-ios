//
//  LinkSummaryPersistenceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol LinkSummarySourceProtocol {
    func saveLinkSummary(_ summary: Summary, userId: String) async throws
    func fetchLinkSummaries(userId: String) async throws -> [Summary]
}
