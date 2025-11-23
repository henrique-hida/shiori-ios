//
//  ObserveSessionUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import Combine

struct ObserveSessionUseCase {
    let authRepo: AuthRepositoryProtocol
    let userRepo: UserRepositoryProtocol
    
    func execute() -> AnyPublisher<UserProfile?, Never> {
        return authRepo.authStatePublisher
            .handleEvents(receiveOutput: { userId in
                print("Auth State Changed. User ID: \(userId ?? "nil")")
            })
            .flatMap { userId -> AnyPublisher<UserProfile?, Never> in
                guard let userId else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return Future { promise in
                    Task {
                        let user = await fetchUserWithRetry(userId: userId)
                        promise(.success(user))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchUserWithRetry(userId: String, attempts: Int = 10) async -> UserProfile? {
        do {
            if let user = try await userRepo.fetchUser(id: userId) {
                print("✅ User Profile loaded: \(user.firstName)")
                return user
            } else {
                throw URLError(.fileDoesNotExist)
            }
        } catch {
            if attempts > 0 {
                print("⏳ Syncing Profile... (Waiting for database: \(attempts) attempts left)")
                try? await Task.sleep(nanoseconds: 500_000_000)
                return await fetchUserWithRetry(userId: userId, attempts: attempts - 1)
            }
            
            print("❌ CRITICAL: Auth exists for \(userId), but Firestore Profile is missing.")
            try? authRepo.signOut()
            return nil
        }
    }
}
