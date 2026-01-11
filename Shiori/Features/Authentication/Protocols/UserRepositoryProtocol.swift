//
//  UserPersistence.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func save(_ user: UserProfile) async throws
    func fetchUser(id: String) async throws -> UserProfile?
}
