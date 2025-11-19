//
//  SignInViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation

@Observable
class SignInViewModel {
    let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var goToHomeView: Bool = false
    var goToSignUpView: Bool = false
    
    func togglePassword() {
        isPasswordVisible.toggle()
    }
    
    func login() async throws {
        Task {
            do {
                try await userService.signIn(email: email, password: password)
                
            } catch {
                print(error)
            }
        }
    }
    
    func goToSignUp() {
        goToSignUpView = true
    }
}
