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
    enum State: Equatable {
        case checking
        case unauthenticated
        case authenticated(UserProfile)
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
            .sink { [weak self] userProfile in
                guard let self = self else { return }
                
                if let user = userProfile {
                    if case .authenticated(let currentUser) = self.state, currentUser.id == user.id {
                        return
                    }
                    self.state = .authenticated(user)
                } else {
                    self.state = .unauthenticated
                }
            }
            .store(in: &cancellables)
    }
    
    func signIn(with user: UserProfile) {
        self.state = .authenticated(user)
    }
    
    func signOut() {
        try? FirebaseAuth.Auth.auth().signOut()
    }
}
