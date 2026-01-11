//
//  Validator.swift
//  Shiori
//
//  Created by Henrique Hida on 04/01/26.
//

import Foundation


struct CredentialsValidator {
    func isValidFirstName(_ firstName: String) throws {
        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            throw ValidationError.emptyField("first name")
        }

        let nameRegex = "^[\\p{L} .'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        
        if !namePredicate.evaluate(with: trimmedName) {
            throw ValidationError.invalidNameFormat
        }
    }
    
    func isValidEmail(_ email: String) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            throw ValidationError.emptyField("email")
        }
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: trimmedEmail.utf16.count)
        let matches = detector?.matches(in: trimmedEmail, options: [], range: range)
        let isMatch = matches?.first?.url?.scheme == "mailto" && matches?.first?.range.length == range.length
        guard isMatch else {
            throw ValidationError.invalidEmailFormat
        }
    }
    
    func isValidPassword(_ password: String) throws{
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPassword.isEmpty else {
            throw ValidationError.emptyField("password")
        }
        guard trimmedPassword.count >= 10 else {
            throw ValidationError.passwordTooShort
        }
        guard trimmedPassword.count <= 64 else {
            throw ValidationError.passwordTooLong
        }
    }
    
    func isValidNewsSubjects(_ newsSubjects: Set<SummarySubject>) throws {
        guard !newsSubjects.isEmpty else {
            throw ValidationError.emptyField("news subjects")
        }
    }
}
