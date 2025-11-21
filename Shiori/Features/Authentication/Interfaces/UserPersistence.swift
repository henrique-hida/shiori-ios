//
//  UserPersistence.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

protocol UserPersistence {
    func save(_ user: AppUser) async throws
    func fetchUser(id: String) async throws -> AppUser?
}
