//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let user: UserProfile
    @State private var viewModel: HomeViewModel
    
    init(user: UserProfile, viewModel: HomeViewModel? = nil) {
        self.user = user
        
        if let vm = viewModel {
            _viewModel = State(initialValue: vm)
        } else {
            let vm = DependencyFactory.shared.makeHomeViewModel()
            _viewModel = State(initialValue: vm)
        }
    }
    
    private var groupedNews: [(Date, [News])] {
        let grouped = Dictionary(grouping: viewModel.newsArticles) { article in
            Calendar.current.startOfDay(for: article.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func headerDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
        
    var body: some View {
        VStack {
            Text("Welcome, \(user.firstName)!")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            if viewModel.isLoading {
                ProgressView("Syncing News...")
                    .frame(maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red)
            } else {
                List {
                    ForEach(groupedNews, id: \.0) { date, articles in
                        Section(header: Text(headerDate(date))) {
                            ForEach(articles) { article in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(article.category)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(article.content)
                                        .font(.body)
                                        .lineLimit(3)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
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
    let schema = Schema([NewsData.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)
    let today = Date()
    for i in 0..<7 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
        
        let newsData = NewsData(
            id: "preview-news-\(i)",
            category: i % 2 == 0 ? "Technology" : "Science",
            content: "This is a summary of news from \(i) days ago. It shows how the app handles history.",
            date: date,
            tone: "formal",
            wasRead: i > 0
        )
        container.mainContext.insert(newsData)
    }
    
    try? container.mainContext.save()
    
    let localRepo = LocalNewsRepository(context: container.mainContext)
    let cloudRepo = MockNewsDatabaseRepository()
    let syncService = NewsSyncService(localRepo: localRepo, cloudRepo: cloudRepo)
    let viewModel = HomeViewModel(syncService: syncService)
    
    let dummyPrefs = NewsPreferences(
        duration: .fast,
        style: .informal,
        subjects: [.technology],
        language: .english,
        arriveTime: 8
    )
    
    let user = UserProfile(
        id: "preview_user",
        firstName: "Preview User",
        isPremium: true,
        language: .english,
        theme: .system,
        weekStreak: [],
        newsPreferences: dummyPrefs
    )
    
    return HomeView(user: user, viewModel: viewModel)
        .modelContainer(container)
}
