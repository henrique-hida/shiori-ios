//
//  ArticlesView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/01/26.
//

import SwiftUI
import SwiftData

struct ArticlesView: View {
    var summary: Summary
    var user: UserProfile
    var audioViewModel: AudioPlayerViewModel
    var isLatest: Bool
    
    var body: some View {
        ZStack {
            // background
            
            // content
            ScrollView {
                VStack(spacing: 20) {
                    Text(summary.title)
                        .bold()
                        .subTitle()
                    
                    AsyncImage(url: URL(string: summary.thumbUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 200)
                    .clipped()
                    .mask(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    
                    Text(.init(summary.content))
                        .textSmall()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            AudioPlayerView(vm: audioViewModel, summary: summary, user: user)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(summary.createdAt.formatted(.dateTime.day().month().year()))
                    .foregroundStyle(.textMuted)
                    .textLarge()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Menu tapped")
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.textMuted)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if !isLatest {
                audioViewModel.cleanup()
            }
        }
    }
    func testDatePrinting() {
        let now = Date()
        let defaultISO = now.formatted(.iso8601.year().month().day())
        print("🇧🇷 Local (Default): \(defaultISO)")
    }
}

#Preview {
    let summary = Summary.sampleSummaries[0].summaryRaw
    let user = UserProfile.sampleUser
    
    let preview = Preview()
    preview.addExamples(ReadLaterData.sampleReadLater)
    let readLaterRepo = ReadLaterRepository(modelContext: preview.container.mainContext)
    let audioPlayerViewModel = AudioPlayerViewModel(audioService: AVFAudioService(), readLaterRepo: readLaterRepo)
    
    return NavigationStack {
        ArticlesView(summary: summary, user: user, audioViewModel: audioPlayerViewModel, isLatest: true)
    }
}
