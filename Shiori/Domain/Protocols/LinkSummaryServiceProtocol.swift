//
//  LinkSummaryServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol LinkSummaryServiceProtocol {
    func summarizeLink(url: URL, style: SummaryStyle, duration: SummaryDuration) async throws -> Summary
}
