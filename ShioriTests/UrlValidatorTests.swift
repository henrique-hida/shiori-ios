//
//  UrlValidatorTests.swift
//  ShioriTests
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation
import Testing
@testable import Shiori

@MainActor
struct URLValidationTests {
    @Test("Valid URLs test")
    func testValidURLs() throws {
        let vm = makeTestViewModel()
        
        #expect(vm.isValidUrl("https://apple.com") == true)
        #expect(vm.isValidUrl("http://bbc.co.uk/news") == true)
    }

    @Test("Invalid URLs test", arguments: [
        "not-a-url",
        "ftp://files.com",
        "http://",
        "www.missing-scheme.com",
        "javascript:alert('hi')"
    ])
    func testInvalidURLs(invalidString: String) throws {
        let vm = makeTestViewModel()
        #expect(vm.isValidUrl(invalidString) == false)
    }
    
    private func makeTestViewModel() -> HomeViewModel {
        return HomeViewModel(
            syncService: MockNewsSyncService(),
            linkSummaryRepository: MockGeminiRepo()
        )
    }
}
