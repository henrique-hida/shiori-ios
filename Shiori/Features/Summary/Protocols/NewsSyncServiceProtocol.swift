//
//  NewsSyncServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation

protocol NewsSyncServiceProtocol {
    func syncAndLoadWeek(for user: UserProfile, isBackgroundTask: Bool) async throws -> [Summary]
}
