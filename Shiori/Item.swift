//
//  Item.swift
//  Shiori
//
//  Created by Henrique Hida on 07/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
