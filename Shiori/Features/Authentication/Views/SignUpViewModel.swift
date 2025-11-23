//
//  SignUpViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class SignUpViewModel {
    var firstName = ""
    var email = ""
    var password = ""
    var isPremium = false
    
    var selectedLanguage: Language = Language.currentSystemLanguage
    var selectedTheme: Theme = .system
    var selectedDuration: NewsDuration = .standard
    var selectedStyle: NewsStyle = .informal
    var selectedSubjects: Set<NewsSubject> = []
    var arriveTime: Int = 6
    
    var signUpStep = 1
    var buttonText = "Next"
    var isLoading = false
    
    var errorMessage: String? = nil
    var registeredUser: UserProfile? = nil
    
    private let signUp: SignUpUseCase
    
    init(signUp: SignUpUseCase) {
        self.signUp = signUp
    }
    
    func handleButtonPress() async {
        errorMessage = nil
        
        if signUpStep == 1 {
            validateStepOne()
        } else {
            if validateStepTwo() {
                await register()
            }
        }
    }
    
    func goToPreviousStep() {
        guard signUpStep > 1 else { return }
        errorMessage = nil
        signUpStep -= 1
        buttonText = "Next"
    }

    private func validateStepOne() {
        let errors = collectValidationErrors()
        if errors.isEmpty {
            advanceToNextStep()
        } else {
            displayErrors(errors)
        }
    }
    
    private func validateStepTwo() -> Bool {
        if selectedSubjects.isEmpty {
            displayErrors(["• Please select at least one subject of interest."])
            return false
        }
        return true
    }

    private func collectValidationErrors() -> [String] {
        return [
            validateFirstName(),
            validateEmail(),
            validatePassword()
        ].compactMap { $0 }
    }

    private func validateFirstName() -> String? {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "• Please fill the First name field."
        }
        return nil
    }

    private func validateEmail() -> String? {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanEmail.isEmpty {
            return "• Please fill the Email field."
        }
        if !cleanEmail.contains("@") || !cleanEmail.contains(".") {
            return "• Invalid email format."
        }
        return nil
    }

    private func validatePassword() -> String? {
        if password.isEmpty {
            return "• Please fill the Password field."
        }
        if password.count < 10 {
            return "• Password must be at least 10 characters long."
        }
        if password.count > 64 {
            return "• Password is too long."
        }
        return nil
    }

    private func advanceToNextStep() {
        withAnimation {
            signUpStep = 2
            buttonText = "Create Account"
        }
    }

    private func displayErrors(_ errors: [String]) {
        withAnimation {
            self.errorMessage = errors.joined(separator: "\n")
        }
    }
    
    func register() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = SignUpRequest(
                email: email,
                password: password,
                firstName: firstName,
                isPremium: isPremium,
                language: selectedLanguage,
                schema: selectedTheme,
                newsDuration: selectedDuration,
                newsStyle: selectedStyle,
                newsSubjects: Array(selectedSubjects),
                newsArriveTime: arriveTime
            )
            
            let user = try await signUp.execute(request: request)
            self.registeredUser = user
            print("Success!")
            
        } catch let error as AuthError {
            handleAuthError(error)
        } catch let error as ValidationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        
        isLoading = false
    }
    
    private func handleAuthError(_ error: AuthError) {
        if case .emailAlreadyInUse = error {
            signUpStep = 1
            buttonText = "Next"
        }
        self.errorMessage = error.errorDescription
    }
}
