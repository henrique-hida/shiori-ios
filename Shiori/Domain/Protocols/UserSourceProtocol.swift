//
//  UserServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol UserSourceProtocol {
    func save(_ user: UserProfile) async throws
    func fetchUser(id: String) async throws -> UserProfile?
}
