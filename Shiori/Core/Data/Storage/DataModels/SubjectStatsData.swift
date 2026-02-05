
//  SubjectStatsData.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

import Foundation
import SwiftData

@Model
final class SubjectStatsData {
    @Attribute(.unique) var id: String
    var year: Int
    var subjectRawValue: String
    var count: Int
    
    init(year: Int, subject: SummarySubject) {
        self.year = year
        self.subjectRawValue = subject.rawValue
        self.id = "\(year)-\(subject.rawValue)"
        self.count = 0
    }
    
    var subject: SummarySubject? {
        SummarySubject(rawValue: subjectRawValue)
    }
}
