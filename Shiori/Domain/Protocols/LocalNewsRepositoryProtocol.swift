//
//  LocalNewsRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol LocalNewsRepositoryProtocol {
    func saveNews(_ summaries: Summary) async throws -> Void
    func fetchNews(forDate date: Date) throws -> Summary?
    func fetchWeekNews() throws -> [Summary]
}
