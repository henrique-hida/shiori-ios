//
//  ShioriTests.swift
//  ShioriTests
//
//  Created by Henrique Hida on 07/11/25.
//

import Testing
import Combine
@testable import Shiori

let validator = CredentialsValidator()

@Suite struct EmailValidatorTests {
    @Test("Valid emails test") func testValidEmails() throws {
        let validEmails: [String] = ["test@example.com", "first.last@company.com.br", "user+tag@gmail.com", "123@digits.net"]
        for email in validEmails {
            try validator.isValidEmail(email)
        }
    }
    
    @Test("Valid trimmed emails test") func testValidTrimmedEmails() throws {
        let invalidRangeEmails: [String] = [" test@example.com", "test@example.com ", "test@example.com\n"]
        for email in invalidRangeEmails {
            try validator.isValidEmail(email)
        }
    }
    
    @Test("Empty emails test") func testEmptyEmails() throws {
        let emptyEmails: [String] = ["", " ", "   "]
        for email in emptyEmails {
            #expect(throws: ValidationError.emptyField("email")) {
                try validator.isValidEmail(email)
            }
        }
    }
    
    @Test("Invalid emails test") func testInvalidEmails() throws {
        let invalidEmails: [String] = ["plainaddress", "@example.com", "user@","user@.com","user@com", "http://google.com", "Email: test@example.com"]
        for email in invalidEmails {
            #expect(throws: ValidationError.invalidEmailFormat) {
                try validator.isValidEmail(email)
            }
        }
    }
}

@Suite struct PasswordValidatorTests {
    @Test("Valid passwords test") func testValidPasswords() throws {
        let validPasswords: [String] = ["Shiori123@", "@!091mjpSc", "passwordsss", "1234567890123456789012345678901234567890123456789012345678901234"]
        for password in validPasswords {
            try validator.isValidPassword(password)
        }
    }
    
    @Test("Empty passwords test") func testEmptyPasswords() throws {
        let emptyPasswords: [String] = ["", " ", "   "]
        for password in emptyPasswords {
            #expect(throws: ValidationError.emptyField("password")) {
                try validator.isValidPassword(password)
            }
        }
    }
    
    @Test("Short passwords test") func testShortPasswords() throws {
        let shortPasswords: [String] = ["Shiori123", "@!091mjpS", "passwords"]
        for password in shortPasswords {
            #expect(throws: ValidationError.passwordTooShort) {
                try validator.isValidPassword(password)
            }
        }
    }
    
    @Test("Long passwords test") func testLongPasswords() throws {
        let longPassword = "12345678901234567890123456789012345678901234567890123456789012345"
        #expect(throws: ValidationError.passwordTooLong) {
            try validator.isValidPassword(longPassword)
        }
    }
}

@Suite struct FirstNameValidatorTests {
    @Test("Valid first names test") func testValidFirstNames() throws {
        let validFirstNames: [String] = ["Henrique", "João Felipe", "O'Connor", "Mary-Jane", " Giovanna"]
        for name in validFirstNames {
            try validator.isValidFirstName(name)
        }
    }
    
    @Test("Empty first names test") func testEmptyFirstNames() throws {
        let emptyFirstNames: [String] = ["", " ", "   "]
        for name in emptyFirstNames {
            #expect(throws: ValidationError.emptyField("first name")) {
                try validator.isValidFirstName(name)
            }
        }
    }
    
    @Test("Invalid first names test") func testInvalidFirstNames() throws {
        let invalidFirstNames: [String] = ["Henrique123", "123", "João!"]
        for name in invalidFirstNames {
            #expect(throws: ValidationError.invalidNameFormat) {
                try validator.isValidFirstName(name)
            }
        }
    }
}

@Suite struct NewsSubjectValidatorTests {
    @Test("Valid news subjects test") func testValidNewsSubjects() throws {
        let validNewsSubjects: [Set<SummarySubject>] = [[SummarySubject.economyAndBusiness, SummarySubject.entertainmentAndCulture, SummarySubject.healthAndScience], [SummarySubject.politic]]
        for newsSubjects in validNewsSubjects {
            try validator.isValidNewsSubjects(newsSubjects)
        }
    }
    
    @Test("Invalid news subjects test") func testInvalidNewsSubjects() throws {
        let invalidNewsSubjects: Set<SummarySubject> = []
        #expect(throws: ValidationError.emptyField("news subjects")) {
            try validator.isValidNewsSubjects(invalidNewsSubjects)
        }
    }
}
