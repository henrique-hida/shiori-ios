//
//  LinkSummarySettings.swift
//  Shiori
//
//  Created by Henrique Hida on 03/02/26.
//

import SwiftUI
import SwiftData

struct LinkSummarySettings: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HomeViewModel
    var user: UserProfile
    
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
                            await viewModel.search(url: url, user: user)
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
                            .foregroundStyle(.textMuted)
                    }
                }
            }
            .navigationTitle("Custom your summary")
            .navigationBarTitleDisplayMode(.inline)
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
    
    return NavigationStack {
        LinkSummarySettings(
            viewModel: viewModel,
            user: UserProfile.sampleUser
        )
    }
}
