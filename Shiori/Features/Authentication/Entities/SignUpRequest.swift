//
//  SignUpRequest.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct SignUpRequest: Sendable {
    let email: String
    let password: String
    let firstName: String
    let isPremium: Bool
    
    let language: Language
    let schema: Theme
    
    let newsDuration: NewsDuration
    let newsStyle: NewsStyle
    let newsSubjects: [NewsSubject]
    let newsArriveTime: Int
}
