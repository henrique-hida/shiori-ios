//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(SessionManager.self) private var sessionManager
    let user: UserProfile
    @State private var viewModel: HomeViewModel
    @State private var audioViewModel: AudioPlayerViewModel
    
    init(user: UserProfile, viewModel: HomeViewModel? = nil) {
        self.user = user
        
        if let vm = viewModel {
            _viewModel = State(initialValue: vm)
        } else {
            let vm = DependencyFactory.shared.makeHomeViewModel()
            _viewModel = State(initialValue: vm)
        }
        
        _audioViewModel = State(initialValue: DependencyFactory.shared.makeAudioPlayerViewModel())
    }
    
    var body: some View {
        ZStack {
            // background
            Rectangle()
                .fill(.bg)
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
                                MainCard(viewModel: viewModel, audioViewModel: audioViewModel, user: user, latestNews: latestNews)
                            } else {
                                MainCard(viewModel: viewModel, audioViewModel: audioViewModel, user: user, latestNews: nil)
                            }
                            if viewModel.weekNewsSummaries.count > 1 {
                                let history = Array(viewModel.weekNewsSummaries.dropFirst())
                                CardCarousel(viewModel: viewModel, weekNews: history)
                            }
                            WeekHistory(viewModel: viewModel)
                            ReadLaterView(viewModel: viewModel)
                            Dashboard(stats: viewModel.subjectStats)
                        }
                    }
                }
                .padding(25)
                .onAppear {
                    Task {
                        await viewModel.loadNews(for: user)
                        await viewModel.loadStreak()
                        await viewModel.loadReadLater()
                        await viewModel.loadStats()
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
            let isLatest = viewModel.weekNewsSummaries.first?.id == article.id
            ArticlesView(
                summary: article,
                user: user,
                audioViewModel: audioViewModel,
                isLatest: isLatest
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.shouldShowSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Image("Isologo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .foregroundStyle(.textMuted)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.historySheetTab = 0
                    viewModel.shouldShowHistorySheet = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.primary)
                }
            }
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.shouldShowLinkSummarySettings) {
            LinkSummarySettings(viewModel: viewModel, user: user)
                .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $viewModel.shouldShowSettings) {
            SettingsView(
                viewModel: DependencyFactory.shared.makeSettingsViewModel(user: user, sessionManager: sessionManager)
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.shouldShowHistorySheet) {
            HistorySheet(viewModel: viewModel, user: user)
                .presentationDetents([.large])
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
        .background(.bgLight)
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
                            .foregroundStyle(.textButton)
                    }
            })
        }
    }
}

private struct MainCard: View {
    @Bindable var viewModel: HomeViewModel
    var audioViewModel: AudioPlayerViewModel
    var user: UserProfile
    var latestNews: Summary?
    var latestNewsDate: String {
        latestNews?.createdAt.formatted(.dateTime.day().month()) ?? "--/--"
    }
    var isCurrentAudio: Bool {
        guard let news = latestNews else { return false }
        return audioViewModel.currentAudioId == news.id
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Last news")
                    .foregroundStyle(.accentSub)
                    .textSmall()
                
                Text(latestNewsDate)
                    .foregroundStyle(.textButton)
                    .newsDate()
            }
            
            Spacer()
            
            HStack {
                Button {
                    if let summary = latestNews {
                        audioViewModel.toggleAudio(summary: summary, language: user.newsPreferences.language)
                    }
                } label: {
                    Circle()
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: (latestNews != nil && audioViewModel.isPlaying(summaryId: latestNews!.id)) ? "pause.fill" : "play.fill")
                                .foregroundStyle(.accentPrimary)
                        )
                        .foregroundStyle(.accentButton)
                }
                
                if isCurrentAudio {
                    Slider(
                        value: Binding(
                            get: { audioViewModel.progress },
                            set: { newValue in
                                audioViewModel.progress = newValue
                            }
                        ),
                        in: 0...1,
                        onEditingChanged: { editing in
                            audioViewModel.isDraggingSlider = editing
                            if !editing {
                                audioViewModel.seek(to: audioViewModel.progress)
                            }
                        }
                    )
                    .tint(.accentButton)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isCurrentAudio)
            
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
        .background(.accentPrimary)
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
                                .foregroundStyle(.textMuted)
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
                    .background(.bgLight)
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
                            .foregroundStyle(isRead ? .accentPrimary : .textMuted.opacity(isFutureDate ? 0.3 : 0.7))
                        
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .bold()
                            .font(.caption)
                            .foregroundStyle(viewModel.isToday(date) ? .textMuted : .textMuted.opacity(0.3))
                            .bold(viewModel.isToday(date))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.bgLight)
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
                                    .foregroundStyle(.textPrimary)
                                    .bold()
                                    .subTitle()
                                
                                Text(summary.createdAt.formatted(.dateTime.month(.abbreviated)))
                            }
                            .padding(.leading, 10)
                        }
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(.bgLight)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                    }
                }
                
                HStack {
                    Text("See all")
                        .foregroundStyle(.accentPrimary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .onTapGesture {
                            viewModel.historySheetTab = 1
                            viewModel.shouldShowHistorySheet = true
                        }
                    
                    Image(systemName: "arrow.forward")
                        .foregroundStyle(.accentPrimary)
                }
                
            }
        }
    }
}

private struct Dashboard: View {
    var stats: [(subject: SummarySubject, percentage: Double)]
    var topStat: (subject: SummarySubject, percentage: Double)? {
        stats.first
    }
    var listStats: [(subject: SummarySubject, percentage: Double)] {
        Array(stats.dropFirst().prefix(3))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Most read subjects this year")
                .bold()
                .subTitle()
            
            VStack(spacing: 15) {
                if stats.isEmpty {
                    Text("Read some news to see your stats!")
                        .foregroundStyle(.textMuted)
                        .padding()
                } else {
                    GeometryReader { geo in
                        HStack(spacing: 15) {
                            if let top = topStat {
                                VStack(alignment: .center) {
                                    Text("\(Int(top.percentage * 100))%")
                                        .title()
                                    
                                    Text(top.subject.rawValue.capitalized)
                                        .foregroundStyle(.accentPrimary)
                                        .bold()
                                        .subTitle()
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: geo.size.width * 0.4)
                            }
                            
                            VStack(spacing: 15) {
                                ForEach(listStats, id: \.subject) { stat in
                                    VStack(spacing: 3) {
                                        HStack {
                                            Text(stat.subject.rawValue.capitalized)
                                                .textSmall()
                                                .lineLimit(1)
                                            Spacer()
                                            Text("\(Int(stat.percentage * 100))%")
                                                .textSmall()
                                        }
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .foregroundStyle(.bg)
                                                .frame(height: 10)
                                            
                                            Capsule()
                                                .foregroundStyle(.accentPrimary)
                                                .frame(width: (geo.size.width * 0.4) * CGFloat(stat.percentage), height: 10)
                                        }
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.5)
                        }
                        .frame(height: geo.size.height, alignment: .center)
                    }
                    .frame(height: 140)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.bgLight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
        }
    }
}

#Preview {
    let preview = Preview(SummaryData.self, ReadLaterData.self, SubjectStatsData.self)
    preview.addExamples(Summary.sampleSummaries)
    preview.addExamples(ReadLaterData.sampleReadLater)
    preview.addExamples(SubjectStatsData.sampleStats)
    
    let context = preview.container.mainContext
    let syncService = NewsSyncService(
        localRepo: LocalNewsRepository(context: context),
        cloudRepo: MockNewsDatabaseRepository()
    )
    
    let viewModel = HomeViewModel(
        syncService: syncService,
        linkSummaryRepo: GeminiLinkSummaryRepository(apiKey: ""),
        cloudLinkPersistence: MockLinkSummaryRepository(),
        cloudNewsRepo: MockNewsDatabaseRepository(),
        historyRepo: ReadingHistoryRepository(modelContext: context),
        readLaterRepo: ReadLaterRepository(modelContext: context),
        statsRepo: SubjectStatsRepository(modelContext: context)
    )
    
    let sessionManager = DependencyFactory.shared.makeSessionManager()
    
    return NavigationStack {
        HomeView(user: UserProfile.sampleUser, viewModel: viewModel)
            .modelContainer(preview.container)
            .environment(sessionManager)
    }
}
