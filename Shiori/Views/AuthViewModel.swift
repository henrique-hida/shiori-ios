//
//  AuthViewMode.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation
import FirebaseAuth
import SwiftData
import Combine
import Observation

enum AuthState {
    case checking
    case signedOut
    case signedIn
}

@MainActor
@Observable
final class AuthViewModel {
    var authState: AuthState = .checking
    var appUser: AppUser?
    
    private let userService: UserService
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(userService: UserService, modelContext: ModelContext) {
        self.userService = userService
        self.modelContext = modelContext
        
        var handle: AuthStateDidChangeListenerHandle?
        
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let firebaseUser = user {
                    await self.fetchAppUser(withId: firebaseUser.uid)
                } else {
                    self.appUser = nil
                    self.authState = .signedOut
                }
            }
        }
        
        AnyCancellable {
            if let handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
        .store(in: &cancellables)
    }
    
    private func fetchAppUser(withId uid: String) async {
        let descriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.id == uid }
        )
        
        do {
            if let user = try modelContext.fetch(descriptor).first {
                self.appUser = user
                self.authState = .signedIn
            } else {
                print("Error: Firebase user exists but no matching AppUser in SwiftData.")
                try? userService.signOut()
                self.appUser = nil
                self.authState = .signedOut
            }
        } catch {
            print("Error fetching user from SwiftData: \(error)")
            self.appUser = nil
            self.authState = .signedOut
        }
    }
}
