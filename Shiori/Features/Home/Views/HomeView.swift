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
    
    var body: some View {
        ZStack {
            // background
            Color(Color.backgroundShiori)
                .ignoresSafeArea()
            
            // content
            ScrollView {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Syncing News...")
                            .frame(maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        ShioriErrorBox(errorMessage: error, type: .error)
                    } else {
                        VStack(spacing: 20) {
                            SearchBar(viewModel: viewModel)
                            if let latestNews = viewModel.newsArticles.first {
                                MainCard(viewModel: viewModel, latestNews: latestNews)
                            } else {
                                MainCard(viewModel: viewModel, latestNews: nil)
                            }
                            if viewModel.newsArticles.count > 1 {
                                let history = Array(viewModel.newsArticles.dropFirst())
                                CardCarousel(viewModel: viewModel, weekNews: history)
                            }
                            NewsStreak(weekNews: viewModel.newsArticles)
                            ReadLater(laterNews: viewModel.newsArticles)
                            Dashboard(weekNews: viewModel.newsArticles)
                        }
                    }
                }
                .padding(25)
                .onAppear {
                    Task {
                        await viewModel.loadNews(for: user)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("Isologo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .foregroundStyle(Color.textMuted)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Menu tapped")
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - SubViews

private struct SearchBar: View {
    @Bindable var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            TextField("Paste your news url here", text: $viewModel.searchInput)
        }
        .frame(height: 10)
        .padding()
        .background(Color(Color.backgroundLightShiori))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        .overlay(alignment: .trailing) {
            Button(action: {
                viewModel.search()
            }, label: {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 60)
                    .overlay {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.textButtonShiori)
                    }
            })
        }
    }
}

private struct MainCard: View {
    @Bindable var viewModel: HomeViewModel
    var latestNews: News?
    var latestNewsDate: String {
        latestNews?.date.formatted(.dateTime.day().month()) ?? "--/--"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Last news")
                    .foregroundStyle(Color.accentSecondaryShiori)
                    .textSmall()
                
                Text(latestNewsDate)
                    .foregroundStyle(Color.textButtonShiori)
                    .newsDate()
            }
            Button {
                viewModel.handlePlayButtonClick()
            } label: {
                Circle()
                    .overlay(
                        Image(systemName: viewModel.isPlayingLastNews ? "pause.fill" : "play.fill")
                            .foregroundStyle(Color.accent)
                    )
                    .foregroundStyle(Color.accentButton)
            }
            
        }
        .padding(20)
        .frame(height: 140, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accent)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
    }
}

private struct CardCarousel: View {
    var viewModel: HomeViewModel
    var weekNews: [News]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(weekNews) { news in
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text(news.date.formatted(.dateTime.weekday(.abbreviated)))
                                .foregroundStyle(Color.textMuted)
                                .textSmall()
                            
                            Text(news.date.formatted(.dateTime.day().month()))
                                .textLarge()
                        }
                    }
                    .padding(20)
                    .frame(width: 100, height: 120, alignment: .topLeading)
                    .background(Color.backgroundLightShiori)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                }
            }
            .padding(.bottom, 5)
        }
    }
}

private struct NewsStreak: View {
    var weekNews: [News]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("News Streak")
                .bold()
                .subTitle()
            
            HStack(spacing: 10) {
                ForEach(weekNews) { news in
                    VStack(spacing: 10) {
                        Image(systemName: news.wasRead ? "flame.fill" : "flame")
                            .font(.system(size: 35))
                            .foregroundStyle(Color.accent)
                        
                        Text(news.date.formatted(.dateTime.weekday(.narrow)))
                    }
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.bgLight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        }
        
    }
}

private struct ReadLater: View {
    var laterNews: [News]
    var lastLaterNews: [News] {
        Array(laterNews.suffix(3))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Later News")
                .bold()
                .subTitle()
            
            VStack(spacing: 10) {
                ForEach(lastLaterNews) { news in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(news.content)
                                .textLarge()
                            Text(news.id)
                                .textSmall()
                        }
                        
                        VStack {
                            Text(news.date.formatted(.dateTime.day().month(.omitted)))
                                .foregroundStyle(Color.text)
                                .bold()
                                .subTitle()
                            
                            Text(news.date.formatted(.dateTime.month(.abbreviated)))
                                .bold()
                        }
                        .padding(.leading, 50)
                    }
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.bgLight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                }
            }
            
            HStack {
                Text("See all")
                    .foregroundStyle(Color.accent)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Image(systemName: "arrow.forward")
                    .foregroundStyle(Color.accent)
            }
            
        }
        
    }
}

private struct Dashboard: View {
    var weekNews: [News]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Most read subjects")
                .bold()
                .subTitle()
            
            HStack(spacing: 10) {
                Spacer()
                VStack(alignment: .center) {
                    Text("40%")
                        .title()
                    
                    Text("Economy")
                        .foregroundStyle(Color.accent)
                        .bold()
                        .subTitle()
                }
                Spacer()
                
                VStack(spacing: 15) {
                    VStack(spacing: 3) {
                        HStack {
                            Text("Politics")
                                .textSmall()
                            Spacer()
                            Text("30%")
                                .textSmall()
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .foregroundStyle(Color.bg)
                                .frame(height: 10)
                                .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                            
                            Capsule()
                                .foregroundStyle(Color.accent)
                                .frame(width: 150*0.3, height: 10)
                        }
                    }
                    VStack(spacing: 3) {
                        HStack {
                            Text("Politics")
                                .textSmall()
                            Spacer()
                            Text("20%")
                                .textSmall()
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .foregroundStyle(Color.bg)
                                .frame(height: 10)
                                .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                            
                            Capsule()
                                .foregroundStyle(Color.accent)
                                .frame(width: 150*0.2, height: 10)
                        }
                    }
                    VStack(spacing: 3) {
                        HStack {
                            Text("Politics")
                                .textSmall()
                            Spacer()
                            Text("10%")
                                .textSmall()
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .foregroundStyle(Color.bg)
                                .frame(height: 10)
                                .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                            
                            Capsule()
                                .foregroundStyle(Color.accent)
                                .frame(width: 150*0.1, height: 10)
                        }
                    }
                }
                .frame(width: 150)
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.bgLight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        }
        
    }
}

#Preview {
    let sessionManager = DependencyFactory.shared.makeSessionManager()
    
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
            wasRead: i % 2 == 0
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
    
    return NavigationStack {
        HomeView(user: user, viewModel: viewModel)
            .modelContainer(container)
            .environment(sessionManager)
    }
}
