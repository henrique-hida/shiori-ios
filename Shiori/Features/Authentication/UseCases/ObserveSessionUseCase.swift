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
            .flatMap { userId -> AnyPublisher<AppUser?, Never> in
                guard let userId else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return Future { promise in
                    Task {
                        do {
                            let user = try await userRepo.fetchUser(id: userId)
                            promise(.success(user))
                        } catch {
                            print("CRITICAL: Auth exists but Local User missing: \(error)")
                            promise(.success(nil))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
