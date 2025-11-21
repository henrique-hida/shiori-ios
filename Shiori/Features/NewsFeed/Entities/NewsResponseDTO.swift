//
//  NewsResponseDTO.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct NewsResponseDTO: Decodable, Sendable {
    let title: String?
    let content: String?
    let thumbLink: String?
    let date: Date?
    let articleLinks: [String]?
    let wasRead: Bool?
}
