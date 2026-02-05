//
//  SessionManager.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation
import Observation
import Combine

@MainActor
@Observable
final class SessionManager {
    enum State: Equatable {
        case checking
        case unauthenticated
        case authenticated(UserProfile)
    }
    
    var state: State = .checking
    
    private let authService: AuthServiceProtocol
    private let userSource: UserSourceProtocol
    
    init(authService: AuthServiceProtocol, userSource: UserSourceProtocol) {
        self.authService = authService
        self.userSource = userSource
        self.start()
    }
    
    private func start() {
        Task {
            for await userId in authService.authStatePublisher.values {
                if let userId {
                    let user = await fetchUserWithRetry(userId: userId)
                    handleStateUpdate(with: user)
                } else {
                    handleStateUpdate(with: nil)
                }
            }
        }
    }
    
    private func handleStateUpdate(with userProfile: UserProfile?) {
        if let user = userProfile {
            if case .authenticated(let currentUser) = self.state, currentUser.id == user.id {
                return
            }
            self.state = .authenticated(user)
        } else {
            self.state = .unauthenticated
        }
    }
    
    private func fetchUserWithRetry(userId: String, maxAttempts: Int = 10) async -> UserProfile? {
        var attemptsLeft = maxAttempts
        while attemptsLeft > 0 {
            do {
                if let user = try await userSource.fetchUser(id: userId) {
                    print("✅ User Profile loaded: \(user.firstName)")
                    return user
                } else {
                    throw URLError(.fileDoesNotExist)
                }
            } catch {
                attemptsLeft -= 1
                print("⏳ Syncing Profile... (\(attemptsLeft) attempts left)")
                try? await Task.sleep(for: .seconds(0.5))
            }
        }
        print("❌ CRITICAL: Auth exists for \(userId), but Firestore Profile is missing.")
        try? authService.signOut()
        return nil
    }
    
    func signIn(with user: UserProfile) {
        self.state = .authenticated(user)
    }
    
    func signOut() {
        try? authService.signOut()
    }
}
