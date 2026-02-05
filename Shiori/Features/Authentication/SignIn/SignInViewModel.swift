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
final class SignInViewModel {
    var email: String = ""
    var password: String = ""
    
    var errorMessage: String? = nil
    var emailErrorMessage: String? = nil
    var passwordErrorMessage: String? = nil
    
    private let authService: AuthServiceProtocol
    private let validator: CredentialsValidator = CredentialsValidator()
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login() async {
        resetErrors()
        do {
            try validator.isValidEmail(email)
            try validator.isValidPassword(password)
            try await authService.signIn(email, password)
        } catch let error as ValidationError {
            applyErrorToField(error)
        } catch let error as AuthError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    private func resetErrors() {
        errorMessage = nil
        emailErrorMessage = nil
        passwordErrorMessage = nil
    }
    
    private func applyErrorToField(_ error: ValidationError) {
        guard let field = error.affectedField else {
            self.errorMessage = error.localizedDescription
            return
        }
        
        switch field {
        case "email":
            self.emailErrorMessage = error.localizedDescription
        case "password":
            self.passwordErrorMessage = error.localizedDescription
        default:
            self.errorMessage = error.localizedDescription
        }
    }
}
