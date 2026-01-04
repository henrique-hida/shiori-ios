//
//  ShioriTests.swift
//  ShioriTests
//
//  Created by Henrique Hida on 07/11/25.
//

import Testing
import Combine
@testable import Shiori

@MainActor
@Suite struct EmailValidatorTests {
    let mockRepo: MockAuthRepository
    let useCase: SignInUseCase
    let vm: SignInViewModel
    
    init() {
        self.mockRepo = MockAuthRepository()
        self.useCase = SignInUseCase(authRepo: mockRepo)
        self.vm = SignInViewModel(signIn: useCase)
    }
    
    @Test("Valid emails test") func testValidEmails() throws {
        let validEmails: [String] = ["test@example.com", "first.last@company.com.br", "user+tag@gmail.com", "123@digits.net"]
        for email in validEmails {
            try vm.isValidEmail(email)
        }
    }
    
    @Test("Valid trimmed emails test") func testValidTrimmedEmails() throws {
        let invalidRangeEmails: [String] = [" test@example.com", "test@example.com ", "test@example.com\n"]
        for email in invalidRangeEmails {
            try vm.isValidEmail(email)
        }
    }
    
    @Test("Empty emails test") func testEmptyEmails() throws {
        let emptyEmails: [String] = ["", " ", "   "]
        for email in emptyEmails {
            #expect(throws: ValidationError.emptyField("email")) {
                try vm.isValidEmail(email)
            }
        }
    }
    
    @Test("Invalid emails test") func testInvalidEmails() throws {
        let invalidEmails: [String] = ["plainaddress", "@example.com", "user@","user@.com","user@com", "http://google.com", "Email: test@example.com"]
        for email in invalidEmails {
            #expect(throws: ValidationError.invalidEmailFormat) {
                try vm.isValidEmail(email)
            }
        }
    }
}

@MainActor
@Suite struct PasswordValidatorTests {
    let mockRepo: MockAuthRepository
    let useCase: SignInUseCase
    let vm: SignInViewModel
    
    init() {
        self.mockRepo = MockAuthRepository()
        self.useCase = SignInUseCase(authRepo: mockRepo)
        self.vm = SignInViewModel(signIn: useCase)
    }
    
    @Test("Valid passwords test") func testValidPasswords() throws {
        let validPasswords: [String] = ["Shiori123@", "@!091mjpSc", "passwordss"]
        for password in validPasswords {
            try vm.isValidPassword(password)
        }
    }
    
    @Test("Empty passwords test") func testEmptyPasswords() throws {
        let emptyPasswords: [String] = ["", " ", "   "]
        for password in emptyPasswords {
            #expect(throws: ValidationError.emptyField("password")) {
                try vm.isValidPassword(password)
            }
        }
    }
    
    @Test("Short passwords test") func testShortPasswords() throws {
        let shortPasswords: [String] = ["Shiori123", "@!091mjpS", "passwords"]
        for password in shortPasswords {
            #expect(throws: ValidationError.passwordTooShort) {
                try vm.isValidPassword(password)
            }
        }
    }
    
    @Test("Long passwords test") func testLongPasswords() throws {
        let longPassword = "12345678901234567890123456789012345678901234567890123456789012345"
        #expect(throws: ValidationError.passwordTooLong) {
            try vm.isValidPassword(longPassword)
        }
    }
}
