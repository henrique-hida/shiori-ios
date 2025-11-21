//
//  SignUpViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class SignUpViewModel {
    var email = ""
    var password = ""
    var firstName = ""
    var isPremium = false
    
    var selectedLanguage: Language = .english
    var selectedTheme: Theme = .system
    var selectedDuration: NewsDuration = .standard
    var selectedStyle: NewsStyle = .imparcial
    var selectedSubjects: Set<NewsSubject> = []
    var arriveTime: Int = 8
    
    var errorMessage: String?
    var isLoading = false
    
    private let signUp: SignUpUseCase
    
    init(signUp: SignUpUseCase) {
        self.signUp = signUp
    }
    
    func register() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let validPassword = try verifyPassword(password: password)
            let validEmail = try verifyEmail(email: email)
            let request = SignUpRequest(
                email: validEmail,
                password: validPassword,
                firstName: firstName,
                isPremium: isPremium,
                language: selectedLanguage,
                schema: selectedTheme,
                newsDuration: selectedDuration,
                newsStyle: selectedStyle,
                newsSubjects: Array(selectedSubjects),
                newsArriveTime: arriveTime
            )
            try await signUp.execute(request: request)
        } catch let error as ValidationError {
            self.errorMessage = error.errorDescription
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "An unexpected error occurred."
            print(error)
        }
        
        isLoading = false
    }
    
    private func verifyPassword(password: String) throws -> String {
        if password.isEmpty {
            throw ValidationError.emptyField("Password")
        } else if password.count < 10 {
            throw ValidationError.passwordTooShort
        } else if password.count > 64 {
            throw ValidationError.passwordTooLong
        }
        return password
    }
    
    private func verifyEmail(email: String) throws -> String {
        if email.isEmpty {
            throw ValidationError.emptyField("Email")
        }
        return email
    }
}
