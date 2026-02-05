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
    var selectedDuration: SummaryDuration = .standard
    var selectedStyle: SummaryStyle = .informal
    var selectedSubjects: Set<SummarySubject> = []
    var selectedArriveTime: Int = 6
    
    var signUpStep = 1
    var buttonText = "Next"
    var isLoading = false
    
    var errorMessage: String? = nil
    var firstNameErrorMessage: String? = nil
    var emailErrorMessage: String? = nil
    var passwordErrorMessage: String? = nil
    
    var registeredUser: UserProfile? = nil
    
    private let validator: CredentialsValidator = CredentialsValidator()
    private let authService: AuthServiceProtocol
    private let userSource: UserSourceProtocol
    
    init(authService: AuthServiceProtocol, userSource: UserSourceProtocol) {
        self.authService = authService
        self.userSource = userSource
    }
    
    func handleButtonPress() async {
        resetErrors()
        
        do {
            if signUpStep == 1 {
                try validator.isValidFirstName(firstName)
                try validator.isValidEmail(email)
                try validator.isValidPassword(password)
                advanceToNextStep()
            } else {
                try validator.isValidNewsSubjects(selectedSubjects)
                try await register()
            }
        } catch let error as ValidationError {
            applyErrorToField(error)
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    func resetErrors() {
        errorMessage = nil
        firstNameErrorMessage = nil
        emailErrorMessage = nil
        passwordErrorMessage = nil
    }
    
    private func advanceToNextStep() {
        withAnimation {
            signUpStep = 2
            buttonText = "Create Account"
        }
    }
    
    func goToPreviousStep() {
        guard signUpStep > 1 else {
            return
        }
        resetErrors()
        signUpStep -= 1
        buttonText = "Next"
    }
    
    func register() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let user = try await signUp()
        self.registeredUser = user
        print("Success!")
    }
    
    func signUp() async throws -> UserProfile {
        let authId = try await authService.signUp(email, password)
        let newUserProfile = UserProfile(
            id: authId,
            firstName: firstName,
            isPremium: false,
            language: selectedLanguage,
            theme: .system,
            newsPreferences: NewsSummaryPreferences(
                duration: selectedDuration,
                style: selectedStyle,
                subjects: Array(selectedSubjects),
                language: selectedLanguage,
                arriveTime: selectedArriveTime
            )
        )
        do {
            try await userSource.save(newUserProfile)
            return newUserProfile
        } catch {
            print("❌ Save Profile failed. Rolling back Auth...")
            try? await authService.deleteCurrentUser()
            throw error
        }
    }
    
    private func handleAuthError(_ error: AuthError) {
        signUpStep = 1
        buttonText = "Next"
        self.errorMessage = error.errorDescription
    }
    
    private func applyErrorToField(_ error: ValidationError) {
        guard let field = error.affectedField else {
            self.errorMessage = error.localizedDescription
            return
        }
        
        switch field {
        case "first name":
            self.firstNameErrorMessage = error.localizedDescription
        case "email":
            self.emailErrorMessage = error.localizedDescription
        case "password":
            self.passwordErrorMessage = error.localizedDescription
        default:
            self.errorMessage = error.localizedDescription
        }
    }
}
