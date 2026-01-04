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
    
    func isValidEmail(_ email: String) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            throw ValidationError.emptyField("email")
        }
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: trimmedEmail.utf16.count)
        let matches = detector?.matches(in: trimmedEmail, options: [], range: range)
        let isMatch = matches?.first?.url?.scheme == "mailto" && matches?.first?.range.length == range.length
        if !isMatch {
            throw ValidationError.invalidEmailFormat
        }
    }
    
    func isValidPassword(_ password: String) throws{
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPassword.isEmpty {
            throw ValidationError.emptyField("password")
        }
        if trimmedPassword.count < 10 {
            throw ValidationError.passwordTooShort
        }
        if trimmedPassword.count > 64 {
            throw ValidationError.passwordTooLong
        }
    }
}
