//
//  HomeViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import Foundation
import Observation

enum HomeState {
    case userLoggedIn
    case userLoggedOut
}

@Observable
final class HomeViewModel {
    let userService: UserService
    var state: HomeState
    
    init(userService: UserService) {
        self.userService = userService
        
        if userService.currentUser != nil {
            state = .userLoggedIn
        } else {
            state = .userLoggedOut
        }
    }
    
    func signOut() throws {
        try userService.signOut()
        self.state = .userLoggedOut
    }
}
