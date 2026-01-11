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
                    } else {
                        VStack(spacing: 20) {
                            if let error = viewModel.errorMessage {
                                ShioriErrorBox(errorMessage: error, type: .error)
                            }
                            SearchBar(viewModel: viewModel)
                            if let latestNews = viewModel.weekNewsSummaries.first {
                                MainCard(viewModel: viewModel, latestNews: latestNews)
                            } else {
                                MainCard(viewModel: viewModel, latestNews: nil)
                            }
                            if viewModel.weekNewsSummaries.count > 1 {
                                let history = Array(viewModel.weekNewsSummaries.dropFirst())
                                CardCarousel(viewModel: viewModel, weekNews: history)
                            }
                            WeekHistory(viewModel: viewModel)
                            ReadLaterView(viewModel: viewModel)
                            Dashboard(weekNews: viewModel.weekNewsSummaries)
                        }
                    }
                }
                .padding(25)
                .onAppear {
                    Task {
                        await viewModel.loadNews(for: user)
                        await viewModel.loadStreak()
                        await viewModel.loadReadLater()
                    }
                }
                .onChange(of: viewModel.selectedSummary) { _, newValue in
                    if newValue != nil {
                        viewModel.trackReadAction(user: user)
                    }
                }
            }
        }
        .navigationDestination(item: $viewModel.selectedSummary) { article in
            ArticlesView(summary: article)
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
        .sheet(isPresented: $viewModel.shouldShowLinkSummarySettings) {
            LinkSummarySettings(viewModel: viewModel)
                .presentationDetents([.height(400)])
        }
    }
}

// MARK: - SubViews

private struct SearchBar: View {
    @Bindable var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            TextField("Paste your news url here", text: $viewModel.searchInput)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .keyboardType(.URL)
        }
        .frame(height: 10)
        .padding()
        .background(Color(Color.backgroundLightShiori))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        .overlay(alignment: .trailing) {
            Button(action: {
                if viewModel.isValidUrl(viewModel.searchInput) {
                    viewModel.shouldShowLinkSummarySettings = true
                }
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
    var latestNews: Summary?
    var latestNewsDate: String {
        latestNews?.createdAt.formatted(.dateTime.day().month()) ?? "--/--"
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
            
            Spacer()
            
            Button {
                viewModel.handlePlayButtonClick()
            } label: {
                Circle()
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: viewModel.isPlayingLastNews ? "pause.fill" : "play.fill")
                            .foregroundStyle(Color.accent)
                    )
                    .foregroundStyle(Color.accentButton)
            }
            
        }
        .frame(height: 140, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background {
            GeometryReader { geo in
                AsyncImage(url: URL(string: latestNews?.thumbUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: geo.size.width * 0.7, height: geo.size.height)
                .clipped()
                .mask(
                    LinearGradient(
                        colors: [.clear, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .background(Color.accent)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        .onTapGesture {
            if let summary = latestNews {
                viewModel.navigateToSummary(summary)
            }
        }
    }
}

private struct CardCarousel: View {
    var viewModel: HomeViewModel
    var weekNews: [Summary]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(weekNews) { news in
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text(news.createdAt.formatted(.dateTime.weekday(.abbreviated)))
                                .foregroundStyle(Color.textMuted)
                                .textSmall()
                            
                            Text(news.createdAt.formatted(.dateTime.day().month()))
                                .textLarge()
                        }
                    }
                    .padding(20)
                    .frame(width: 100, height: 120, alignment: .topLeading)
                    .background {
                        GeometryReader { geo in
                            AsyncImage(url: URL(string: news.thumbUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: geo.size.width, height: geo.size.height * 0.6)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    colors: [.clear, .black],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .background(Color.backgroundLightShiori)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                    .onTapGesture {
                        viewModel.navigateToSummary(news)
                    }
                }
            }
            .padding(.bottom, 5)
        }
    }
}

private struct WeekHistory: View {
    var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("News Streak")
                .bold()
                .subTitle()
            
            HStack(spacing: 10) {
                ForEach(viewModel.currentWeekDates, id: \.self) { date in
                    let dateKey = viewModel.getDateKey(date)
                    let isRead = viewModel.currentWeekStreak[dateKey] ?? false
                    let isFutureDate = viewModel.isFuture(date)
                    
                    VStack(spacing: 10) {
                        Image(systemName: isRead ? "flame.fill" : "flame")
                            .font(.system(size: 30))
                            .foregroundStyle(isRead ? Color.accent : Color.textMuted.opacity(isFutureDate ? 0.3 : 0.7))
                        
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .bold()
                            .font(.caption)
                            .foregroundStyle(viewModel.isToday(date) ? Color.textMuted : Color.textMuted.opacity(0.3))
                            .bold(viewModel.isToday(date))
                    }
                    .frame(maxWidth: .infinity)
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

private struct ReadLaterView: View {
    var viewModel: HomeViewModel
    var readLaterPreview: [ReadLater] {
        Array(viewModel.readLaterSummaries.prefix(3))
    }
    
    var body: some View {
        if !readLaterPreview.isEmpty {
            VStack(spacing: 15) {
                Text("Later News")
                    .bold()
                    .subTitle()
                
                VStack(spacing: 10) {
                    ForEach(readLaterPreview) { summary in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(summary.title)
                                    .textLarge()
                                    .lineLimit(1)
                                Text(summary.id)
                                    .textSmall()
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(summary.createdAt.formatted(.dateTime.day().month(.omitted)))
                                    .foregroundStyle(Color.text)
                                    .bold()
                                    .subTitle()
                                
                                Text(summary.createdAt.formatted(.dateTime.month(.abbreviated)))
                            }
                            .padding(.leading, 10)
                        }
                        .frame(height: 40)
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
}

private struct Dashboard: View {
    var weekNews: [Summary]
    
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

private struct LinkSummarySettings: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    ShioriSelector(title: "Select a style", icon: "newspaper", options: SummaryStyle.allCases, selection: $viewModel.linkSummaryStyle)
                    
                    ShioriSelector(title: "Select a duration", icon: "clock", options: SummaryDuration.allCases, selection: $viewModel.linkSummaryDuration)
                    
                }
                ShioriButton(title: "Generate summary", style: .primary) {
                    Task {
                        if let url = viewModel.validUrl {
                            await viewModel.search(url: url)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.top, 0)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("Custom your summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

@MainActor
func makePreviewDependencies() -> (ModelContainer, HomeViewModel, UserProfile, SessionManager) {
    let sessionManager = DependencyFactory.shared.makeSessionManager()
    let schema = Schema([SummaryData.self, ReadLaterData.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)
    
    let today = Date()
    let thumbs = [
        "https://s2-g1.glbimg.com/3XJW8mtAXe4jrnXB8B149_d4jm8=/0x0:1248x702/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2026/T/C/wTq3RuT8KAkBmPw6b8Nw/1-reuters-bloco12.jpg",
        "https://s2-g1.glbimg.com/0JXVCAyWVMO9w30Yk4qOSZUu7Ss=/0x0:4288x2848/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2026/i/u/xcqHrtSKi0P7BxeosVmw/ross-parmly-rf6ywhvkrly-unsplash.jpg",
        "https://s2-g1.glbimg.com/NqAipQiZ_MfwlOeayDsG23X-tAo=/0x0:5500x3668/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2025/R/Z/I8xuVGStCgJiGF04jD4w/2025-03-15t173620z-1738905982-rc2qdda6qmye-rtrmadp-3-greenland-protest.jpg",
        "https://ichef.bbci.co.uk/news/1536/cpsprodpb/6c3d/live/0fbabe30-eec5-11f0-b5f7-49f0357294ff.jpg.webp",
        "https://ichef.bbci.co.uk/images/ic/1920xn/p0mrqq2n.jpg.webp",
        "https://ichef.bbci.co.uk/images/ic/1920xn/p0ms3mr2.jpg.webp",
        "https://static.toiimg.com/thumb/msid-126465790,imgsize-34908,width-400,resizemode-4/trump-cuban-flag.jpg"
    ]
    
    for i in 0..<7 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
        let summaryStruct = Summary(
            id: "preview-news-\(i)",
            title: "Daily Briefing \(i)",
            content: "This is a summary of news from \(i) days ago.",
            createdAt: date,
            thumbUrl: thumbs[i],
            sources: [],
            subjects: i % 2 == 0 ? [.technology] : [.healthAndScience],
            type: .news
        )

        let summaryData = SummaryData(
            id: summaryStruct.id,
            title: summaryStruct.title,
            content: summaryStruct.content,
            createdAt: summaryStruct.createdAt,
            thumbUrl: summaryStruct.thumbUrl,
            sources: summaryStruct.sources,
            subjects: summaryStruct.subjects,
            type: summaryStruct.type
        )
        container.mainContext.insert(summaryData)
        
        if i < 3 {
            let readLaterItem = ReadLaterData(summary: summaryStruct)
            container.mainContext.insert(readLaterItem)
        }
    }
    
    let localRepo = LocalNewsRepository(context: container.mainContext)
    let cloudRepo = MockNewsDatabaseRepository()
    let syncService = NewsSyncService(localRepo: localRepo, cloudRepo: cloudRepo)
    let linkSummaryRepo = GeminiLinkSummaryRepository(apiKey: "")
    let historyRepo = ReadingHistoryRepository(modelContext: container.mainContext)
    let readLaterRepo = ReadLaterRepository(modelContext: container.mainContext)
    
    let viewModel = HomeViewModel(
        syncService: syncService,
        linkSummaryRepo: linkSummaryRepo,
        historyRepo: historyRepo,
        readLaterRepo: readLaterRepo
    )
    
    let dummyPrefs = NewsSummaryPreferences(
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
        newsPreferences: dummyPrefs
    )
    
    return (container, viewModel, user, sessionManager)
}

#Preview {
    let (container, viewModel, user, sessionManager) = makePreviewDependencies()
    
    NavigationStack {
        HomeView(user: user, viewModel: viewModel)
            .modelContainer(container)
            .environment(sessionManager)
    }
}
