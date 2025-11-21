//
//  NewsRequestBody.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct NewsRequestBody: Encodable, Sendable {
    let newsDuration: NewsDuration
    let newsStyle: NewsStyle
    let newsSubjects: [NewsSubject]
    let newsLanguage: Language
    let newsArriveTime: Int
}
