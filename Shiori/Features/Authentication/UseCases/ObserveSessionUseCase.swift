//
//  ObserveSessionUseCase.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import Combine

struct ObserveSessionUseCase {
    let authRepo: AuthRepository
    let userRepo: UserPersistence
    
    func execute() -> AnyPublisher<AppUser?, Never> {
        return authRepo.authStatePublisher
            .handleEvents(receiveOutput: { userId in
                print("Auth State Changed. User ID: \(userId ?? "nil")")
            })
            .flatMap { userId -> AnyPublisher<AppUser?, Never> in
                guard let userId else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return Future { promise in
                    Task {
                        let user = await fetchUserOnMainThread(userId: userId)
                        promise(.success(user))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor
    private func fetchUserOnMainThread(userId: String, attempts: Int = 10) async -> AppUser? {
        do {
            if let user = try await userRepo.fetchUser(id: userId) {
                print("✅ Local User found")
                return user
            } else {
                throw URLError(.fileDoesNotExist)
            }
        } catch {
            if attempts > 0 {
                print("⏳ User syncing... (Waiting for database: \(attempts) attempts left)")
                try? await Task.sleep(nanoseconds: 500_000_000)
                return await fetchUserOnMainThread(userId: userId, attempts: attempts - 1)
            }
            print("❌ CRITICAL: Firebase has user \(userId), but Local DB is empty.")
            try? authRepo.signOut()
            
            return nil
        }
    }
}
