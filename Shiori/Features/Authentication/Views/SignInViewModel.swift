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
    
    func isValidEmail(_ email: String) -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: email.utf16.count)
        let matches = detector?.matches(in: email, options: [], range: range)
        return matches?.first?.url?.scheme == "mailto" && matches?.first?.range.length == range.length
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPassword.count >= 10 {
            return true
        }
        return false
    }
}
