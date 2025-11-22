//
//  SessionManager.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation
import Observation
import Combine
import FirebaseAuth

@MainActor
@Observable
final class SessionManager {
    enum State {
        case checking
        case unauthenticated
        case authenticated(AppUser)
    }
    
    var state: State = .checking
    
    private var cancellables = Set<AnyCancellable>()
    private let observeSession: ObserveSessionUseCase
    
    init(observeSession: ObserveSessionUseCase) {
        self.observeSession = observeSession
        self.start()
    }

    private func start() {
        observeSession.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user {
                    self?.verifyUserExistsOnServer { exists in
                        if exists {
                            self?.state = .authenticated(user)
                        } else {
                            self?.state = .unauthenticated
                        }
                    }
                } else {
                    self?.state = .unauthenticated
                }
            }
            .store(in: &cancellables)
    }

    private func verifyUserExistsOnServer(completion: @escaping (Bool) -> Void) {
        if let firebaseUser = FirebaseAuth.Auth.auth().currentUser {
            firebaseUser.reload { error in
                if let error = error {
                    print("Erro de validação (usuário pode ter sido deletado): \(error)")
                    try? FirebaseAuth.Auth.auth().signOut()
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
}
