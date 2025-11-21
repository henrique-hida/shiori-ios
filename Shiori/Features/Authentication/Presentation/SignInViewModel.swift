//
//  SignInViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation
import Observation

@Observable
class SignInViewModel {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var goToHomeView: Bool = false
    var goToSignUpView: Bool = false
    
    private let signIn: SignInUseCase
    
    init(signIn: SignInUseCase) {
        self.signIn = signIn
    }
    
    func togglePassword() {
        isPasswordVisible.toggle()
    }
    
    func login() async throws {
        Task {
            do {
                try await signIn.execute(email: email, password: password)
            } catch {
                print(error)
            }
        }
    }
    
    func goToSignUp() {
        goToSignUpView = true
    }
}
