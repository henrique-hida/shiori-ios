//
//  LinkSummarizerProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation

protocol LinkSummaryRepositoryProtocol {
    func summarizeLink(url: URL, style: SummaryStyle, duration: SummaryDuration) async throws -> Summary
}
