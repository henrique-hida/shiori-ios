//
//  AudioPlayerView.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import SwiftUI
import SwiftData

struct AudioPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    var vm: AudioPlayerViewModel
    let summary: Summary
    let user: UserProfile
    
    @State private var progress: Double = 0.3
    @State private var showSources = false
    
    var body: some View {
        VStack(spacing: 10) {
            Slider(
                value: Binding(
                    get: { vm.progress },
                    set: { newValue in
                        vm.progress = newValue
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    vm.isDraggingSlider = editing
                    if !editing {
                        vm.seek(to: vm.progress)
                    }
                }
            )
            .animation(.linear(duration: 0.3), value: vm.progress)
            .tint(.accentPrimary)
            
            ZStack(alignment: .center) {
                HStack(spacing: 30) {
                    Image(systemName: "10.arrow.trianglehead.counterclockwise")
                        .font(.system(size: 24))
                        .foregroundStyle(.accentPrimary)
                    
                    Button {
                        vm.toggleAudio(summary: summary, language: user.newsPreferences.language)
                    } label: {
                        Circle()
                            .overlay(
                                Image(systemName: vm.isPlaying(summaryId: summary.id) ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.bg)
                            )
                            .foregroundStyle(.accentPrimary)
                            .frame(width: 60)
                    }
                    
                    Image(systemName: "10.arrow.trianglehead.clockwise")
                        .font(.system(size: 24))
                        .foregroundStyle(.accentPrimary)
                }
                
                HStack {
                    Spacer()
                    
                    Menu {
                        Button("Save to read later", systemImage: "bookmark") {
                            Task {
                                await vm.readLaterRepo.save(summary, user: user)
                                dismiss()
                            }
                        }
                        
                        Button("View sources", systemImage: "link") {
                            showSources = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.textMuted)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showSources) {
            SourcesSheet(sources: summary.sources)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct SourcesSheet: View {
    let sources: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if sources.isEmpty {
                    Text("No sources available")
                        .foregroundStyle(.textMuted)
                } else {
                    ForEach(sources, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            Link(destination: url) {
                                HStack(spacing: 10) {
                                    Image(systemName: "safari")
                                        .foregroundStyle(.accentPrimary)
                                    
                                    VStack(alignment: .leading) {
                                        Text(url.host() ?? urlString)
                                            .foregroundStyle(.textPrimary)
                                            .font(.headline)
                                        
                                        Text("Click to read the original article")
                                            .foregroundStyle(.textMuted)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundStyle(.accentPrimary)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.bgLight)
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(ReadLaterData.sampleReadLater)
    
    let readLaterRepo = ReadLaterRepository(modelContext: preview.container.mainContext)
    let audioPlayerViewModel = AudioPlayerViewModel(
        audioService: AVFAudioService(),
        readLaterRepo: readLaterRepo
    )
    
    return AudioPlayerView(
        vm: audioPlayerViewModel,
        summary: Summary.sampleSummaries[0].summaryRaw,
        user: UserProfile.sampleUser
    )
}
