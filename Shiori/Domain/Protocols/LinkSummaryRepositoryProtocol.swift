//
//  LinkSummaryRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol LinkSummaryRepositoryProtocol {
    func summarizeLink(url: URL, style: SummaryStyle, duration: SummaryDuration) async throws -> Summary
}
