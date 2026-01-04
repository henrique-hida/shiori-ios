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
    
    @Test("Valid email tests") func testValidEmail() {
        let validEmails: [String] = ["test@example.com", "first.last@company.com.br", "user+tag@gmail.com", "123@digits.net"]
        for email in validEmails {
            #expect(vm.isValidEmail(email) == true)
        }
    }
    
    @Test("Invalid email tests") func testInvalidEmail() {
        let invalidEmails: [String] = ["", "plainaddress", "@example.com", "user@","user@.com","user@com", "http://google.com"]
        for email in invalidEmails {
            #expect(vm.isValidEmail(email) == false)
        }
    }
    
    @Test("Invalid range email tests") func testInvalidEmailRange() {
        let invalidRangeEmails: [String] = [" test@example.com", "test@example.com ", "Email: test@example.com", "test@example.com\n"]
        for email in invalidRangeEmails {
            #expect(vm.isValidEmail(email) == false)
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
    
    @Test("Valid passwords tests") func testValidPassword() {
        let validPasswords: [String] = ["Shiori123@", "@!091mjpSc", "passwordss"]
        for password in validPasswords {
            #expect(vm.isValidPassword(password) == true)
        }
    }
    
    @Test("Invalid passwords tests") func testInvalidPassword() {
        let invalidPasswords: [String] = ["Shiori123", "@!091mjpS", "passwords", "", " "]
        for password in invalidPasswords {
            #expect(vm.isValidPassword(password) == false)
        }
    }
}
