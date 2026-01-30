//
//  ReadLaterSample.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import Foundation

extension ReadLaterData {
    static var sampleReadLater: [ReadLaterData] {
        Summary.sampleSummaries.map {ReadLaterData(summary: $0.summaryRaw)}
    }
}
