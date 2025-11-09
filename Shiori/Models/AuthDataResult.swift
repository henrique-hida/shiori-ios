//
//  AuthDataResult.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import FirebaseAuth

struct AuthDataResult {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}
