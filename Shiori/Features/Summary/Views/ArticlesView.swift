//
//  ArticlesView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/01/26.
//

import SwiftUI

struct ArticlesView: View {
    var summary: Summary
    var user: UserProfile
    var viewModel: ArticlesViewModel = DependencyFactory.shared.makeArticlesViewModel()
        
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
                    
                    Text(summary.content)
                        .textSmall()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            AudioPlayer(viewModel: viewModel, summary: summary, user: user)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(summary.createdAt.formatted(.dateTime.day().month().year()))
                    .foregroundStyle(Color.textMuted)
                    .textLarge()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Menu tapped")
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    func testDatePrinting() {
        let now = Date()
        let defaultISO = now.formatted(.iso8601.year().month().day())
        print("🇧🇷 Local (Default): \(defaultISO)")
    }
}

private struct AudioPlayer: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ArticlesViewModel
    let summary: Summary
    let user: UserProfile
    var isPlaying: Bool = false
    
    @State private var progress: Double = 0.3
    @State private var showSources = false
    
    var body: some View {
        VStack(spacing: 10) {
            Slider(value: $progress)
                .tint(Color.accent)
            
            ZStack(alignment: .center) {
                HStack(spacing: 30) {
                    Image(systemName: "10.arrow.trianglehead.counterclockwise")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accent)
                    
                    Circle()
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.bg)
                        )
                        .foregroundStyle(Color.accent)
                        .frame(width: 60)
                    
                    Image(systemName: "10.arrow.trianglehead.clockwise")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accent)
                }
                
                HStack {
                    Spacer()
                    
                    Menu {
                        Button("Save to read later", systemImage: "bookmark") {
                            Task {
                                await viewModel.readLaterRepo.save(summary, user: user)
                                dismiss()
                            }
                        }
                        
                        Button("View sources", systemImage: "link") {
                            showSources = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
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
                        .foregroundStyle(Color.textMuted)
                } else {
                    ForEach(sources, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            Link(destination: url) {
                                HStack(spacing: 10) {
                                    Image(systemName: "safari")
                                        .foregroundStyle(Color.accent)
                                    
                                    VStack(alignment: .leading) {
                                        Text(url.host() ?? urlString)
                                            .foregroundStyle(Color.text)
                                            .font(.headline)
                                        
                                        Text("Click to read the original article")
                                            .foregroundStyle(Color.textMuted)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.accent)
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
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
        }
    }
}

#Preview {
    let summary = Summary(
        id: "mock-1",
        title: "CNH 2026: veja como renovar a habilitação automaticamente e de graça",
        content: "Para ser considerado bom condutor, o motorista precisa cumprir os seguintes critérios: 🪪 Não ter pontos registrados na CNH nos últimos 12 meses; 🚨 Não ter infrações de trânsito registradas no documento no mesmo período; 📝 Estar cadastrado no Registro Nacional Positivo de Condutores (RNPC). Para aderir ao RNPC e ter a CNH renovada de graça, o motorista deve: Abrir o aplicativo CNH Brasil; Selecionar a opção “Condutor”; Acessar Cadastro Positivo; Tocar em Autorizar participação.",
        createdAt: Date(),
        thumbUrl: "https://s2-g1.glbimg.com/6Z1wTV5tuVFG9LHWQMUm_ibdw1Y=/0x57:1280x777/1080x608/smart/filters:max_age(3600)/https://i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2025/G/e/Jn2qE3RrK1oXg1cKsxDg/design-sem-nome.jpg",
        sources: ["https://g1.globo.com/carros/noticia/2026/01/10/cnh-2026-veja-como-renovar-a-habilitacao-automaticamente-e-de-graca.ghtml", "https://g1.globo.com/pe/pernambuco/blog/viver-noronha/post/2026/01/10/advogada-mordida-por-tubarao-em-fernando-de-noronha-relata-senti-forte-mordida-na-perna.ghtml"],
        subjects: [.economyAndBusiness, .entertainmentAndCulture],
        type: .news
    )
    
    let dummyUser = UserProfile(
        id: "preview_user",
        firstName: "Previewer",
        isPremium: true,
        language: .english,
        theme: .system,
        newsPreferences: NewsSummaryPreferences(
            duration: .standard,
            style: .funny,
            subjects: [],
            language: .english,
            arriveTime: 8
        )
    )
    
    NavigationStack {
        ArticlesView(summary: summary, user: dummyUser)
    }
}
