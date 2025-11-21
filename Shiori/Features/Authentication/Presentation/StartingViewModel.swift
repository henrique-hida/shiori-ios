//
//  StartingViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 18/11/25.
//

import Foundation
import Observation

@Observable
class StartingViewModel {
    var goToSignInView: Bool = false
    var goToSignUpView: Bool = false
    
    func login() {
        goToSignInView = true
    }
    
    func register() {
        goToSignUpView = true
    }
}
