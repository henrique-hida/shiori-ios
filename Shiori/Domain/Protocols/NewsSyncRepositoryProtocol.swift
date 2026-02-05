//
//  NewsSyncServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol NewsSyncRepositoryProtocol {
    func syncAndLoadWeek(for user: UserProfile, isBackgroundTask: Bool) async throws -> [Summary]
}
