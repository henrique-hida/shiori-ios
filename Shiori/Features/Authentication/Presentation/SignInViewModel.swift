//
//  SignInViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
class SignInViewModel {
    var email: String = ""
    var password: String = ""
    var goToSignUpView: Bool = false
    
    var errorMessage: String? = nil
    
    private let signIn: SignInUseCase
    
    init(signIn: SignInUseCase) {
        self.signIn = signIn
    }
    
    func login() async {
        errorMessage = nil
        do {
            try await signIn.execute(email: email, password: password)
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    func goToSignUp() {
        goToSignUpView = true
    }
}
