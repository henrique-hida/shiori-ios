//
//  SettingsViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 03/02/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var selectedStyle: SummaryStyle
    var selectedDuration: SummaryDuration
    var selectedArriveTime: Int
    var selectedSubjects: Set<SummarySubject>
    
    var selectedLanguage: Language
    var isDarkMode: Bool
    var allowEmailNotifications: Bool
    
    var isLoading: Bool = false
    
    private var user: UserProfile
    private let userSource: UserSourceProtocol
    private let sessionManager: SessionManager
        
    init(user: UserProfile, userSource: UserSourceProtocol, sessionManager: SessionManager) {
        self.user = user
        self.userSource = userSource
        self.sessionManager = sessionManager
        
        self.selectedStyle = user.newsPreferences.style
        self.selectedDuration = user.newsPreferences.duration
        self.selectedArriveTime = user.newsPreferences.arriveTime
        self.selectedSubjects = Set(user.newsPreferences.subjects)
        self.selectedLanguage = user.newsPreferences.language
        
        self.isDarkMode = (user.theme == .dark)
        self.allowEmailNotifications = false
    }
    
    func saveChanges(onSuccess: () -> Void) async {
        isLoading = true
        
        user.newsPreferences.style = selectedStyle
        user.newsPreferences.duration = selectedDuration
        user.newsPreferences.arriveTime = selectedArriveTime
        user.newsPreferences.subjects = Array(selectedSubjects)
        user.newsPreferences.language = selectedLanguage
        user.theme = isDarkMode ? .dark : .light
        
        do {
            try await userSource.save(user)
            onSuccess()
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
        
        isLoading = false
    }
    
    var hoursOptions: [Int] { Array(0...23) }
    func formatHour(_ hour: Int) -> String { "\(hour)h" }
    
    func translateStyle(_ style: SummaryStyle) -> String {
        return style.rawValue.capitalized
    }
}
