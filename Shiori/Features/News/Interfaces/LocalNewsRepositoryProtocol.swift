//
//  LocalNewsRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation

protocol LocalNewsRepositoryProtocol {
    func saveNews(_ articles: [News]) async throws -> Void
    func fetchNews(forDate date: Date) throws -> [News]
    func fetchWeekNews() throws -> [News]
    func updateReadStatus(newsID: String, wasRead: Bool) async throws
}
