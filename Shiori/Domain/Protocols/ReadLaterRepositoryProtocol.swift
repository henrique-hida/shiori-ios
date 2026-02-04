//
//  ReadLaterRepositoryProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 04/02/26.
//

import Foundation

protocol ReadLaterRepositoryProtocol {
    func getAll() async -> [ReadLater]
    func save(_ summary: Summary, user: UserProfile) async
    func remove(id: String, user: UserProfile) async
    func isSaved(id: String) -> Bool
}
