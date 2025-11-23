//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI

struct HomeView: View {
    let user: UserProfile
    @State private var viewModel: HomeViewModel
    
    init(user: UserProfile) {
        self.user = user
        let vm = DependencyFactory.shared.makeHomeViewModel()
        _viewModel = State(initialValue: vm)
    }
        
    var body: some View {
        VStack {
            Text("Welcome, \(user.firstName)!")
                .font(.title)
            
            if viewModel.isLoading {
                ProgressView("Loading News...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)").foregroundStyle(.red)
            } else {
                List(viewModel.newsArticles) { article in
                    VStack(alignment: .leading) {
                        Text(article.category).font(.headline)
                        Text(article.content).font(.body)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadNews(for: user)
            }
        }
    }
}

#Preview {
    let dummyPrefs = NewsPreferences(
        duration: .fast,
        style: .informal,
        subjects: [.technology],
        language: .english,
        arriveTime: 8
    )
    
    let user = UserProfile(
        id: "preview_id",
        firstName: "Preview User",
        isPremium: true,
        language: .english,
        theme: .system,
        weekStreak: [],
        newsPreferences: dummyPrefs
    )
    
    return HomeView(user: user)
}
