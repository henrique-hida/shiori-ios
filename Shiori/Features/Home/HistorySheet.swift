//
//  HistorySheet.swift
//  Shiori
//
//  Created by Henrique Hida on 02/02/26.
//

import SwiftUI
import SwiftData

struct HistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HomeViewModel
    var user: UserProfile
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Options", selection: $selectedTab) {
                        Text("Last News").tag(0)
                        Text("Read Later").tag(1)
                        Text("Link Summaries").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        SummariesListView(viewModel: viewModel, user: user)
                            .tag(0)
                        
                        ReadLaterListView(viewModel: viewModel, user: user)
                            .tag(1)
                        
                        LinkNewsListView(viewModel: viewModel, user: user)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.textMuted)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private struct SummariesListView: View {
    var viewModel: HomeViewModel
    var user: UserProfile
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                if !viewModel.weekNewsSummaries.isEmpty {
                    Section {
                        ForEach(viewModel.weekNewsSummaries) { summary in
                            GridNewsCard(summary: summary) {
                                viewModel.navigateToSummary(summary)
                            }
                        }
                    } header: {
                        Text("Last 7 Days")
                            .foregroundStyle(.textMuted)
                            .textLarge()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                }
                
                if !viewModel.cloudHistorySummaries.isEmpty {
                    Section {
                        ForEach(viewModel.cloudHistorySummaries) { summary in
                            GridNewsCard(summary: summary) {
                                viewModel.navigateToSummary(summary)
                            }
                        }
                    } header: {
                        Text("Last 30 Days")
                            .foregroundStyle(.textMuted)
                            .textLarge()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 50)
                        .gridCellColumns(2)
                }
                
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task { await viewModel.loadMoreCloudHistory(user: user) }
                    }
            }
            .padding()
        }
        .background(Color.bg)
    }
}
private struct GridNewsCard: View {
    let summary: Summary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(summary.createdAt.formatted(.dateTime.day().month()))
                    .newsDate()
                    .bold()
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(12)
                
                Spacer()
                
                Text(summary.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(12)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                GeometryReader { geo in
                    AsyncImage(url: URL(string: summary.thumbUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.6), .black.opacity(0.1), .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct LargeNewsCard: View {
    let title: String
    let date: Date
    let thumbUrl: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(20)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                GeometryReader { geo in
                    AsyncImage(url: URL(string: thumbUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.6), .black.opacity(0.2), .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct ReadLaterListView: View {
    var viewModel: HomeViewModel
    var user: UserProfile
    
    var body: some View {
        ScrollView {
            if viewModel.readLaterSummaries.isEmpty {
                ContentUnavailableView("No saved news", systemImage: "bookmark.slash")
                    .padding(.top, 50)
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.readLaterSummaries, id: \.id) { readLater in
                        LargeNewsCard(
                            title: readLater.title,
                            date: readLater.savedAt,
                            thumbUrl: readLater.thumbUrl
                        ) {
                            viewModel.navigateToSummary(readLater.asSummary)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.toggleReadLater(readLater.asSummary, user: user)
                            } label: {
                                Label("Remove from Read Later", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.bg)
    }
}

private struct LinkNewsListView: View {
    var viewModel: HomeViewModel
    var user: UserProfile
    
    var body: some View {
        ScrollView {
            if viewModel.linkNewsSummaries.isEmpty {
                ContentUnavailableView("No link summaries", systemImage: "link")
                    .padding(.top, 50)
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.linkNewsSummaries) { summary in
                        LargeNewsCard(
                            title: summary.title,
                            date: summary.createdAt,
                            thumbUrl: summary.thumbUrl
                        ) {
                            viewModel.navigateToSummary(summary)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.bg)
        .refreshable {
            await viewModel.loadLinkSummaries(user: user)
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
    
    let sampleSummaries = Summary.sampleSummaries.map {$0.summaryRaw}
    
    let sampleReadLater = ReadLaterData.sampleReadLater.map { data in
        ReadLater(from: data)
    }
    
    viewModel.weekNewsSummaries = sampleSummaries
    viewModel.readLaterSummaries = sampleReadLater
    viewModel.cloudHistorySummaries = sampleSummaries
    
    return NavigationStack {
        HistorySheet(viewModel: viewModel, user: UserProfile.sampleUser)
    }
}
