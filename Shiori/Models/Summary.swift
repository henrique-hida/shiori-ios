//
//  Summary.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import SwiftData

@Model
class Summary {
    @Attribute(.unique) private(set) var id: UUID
    private(set) var origin: String
    private(set) var title: String
    private(set) var content: String
    private(set) var isAccurate: Bool
    private(set) var accuracyProofLinks: [String]
    private(set) var summarizedAt: Date
    
    init(id: UUID, origin: String, title: String, content: String, isAccurate: Bool, accuracyProofLinks: [String], summarizedAt: Date) {
        self.id = id
        self.origin = origin
        self.title = title
        self.content = content
        self.isAccurate = isAccurate
        self.accuracyProofLinks = accuracyProofLinks
        self.summarizedAt = summarizedAt
    }
}
