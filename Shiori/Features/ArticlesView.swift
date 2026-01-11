//
//  ArticlesView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/01/26.
//

import SwiftUI

struct ArticlesView: View {
    var summary: Summary
        
    var body: some View {
        ZStack {
            // background
            
            // content
            ScrollView {
                Text(summary.content)
                    .textSmall()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            AudioPlayer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(summary.createdAt.formatted(.dateTime.day().month().year()))
                    .bold()
                    .subTitle()
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
    var isPlaying: Bool = false
    @State private var progress: Double = 0.3
    
    var body: some View {
        VStack(spacing: 20) {
            Slider(value: $progress)
                .tint(Color.accent)
            
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
                    .frame(width: 50)
                
                Image(systemName: "10.arrow.trianglehead.clockwise")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accent)
            }
        }
        .padding(.horizontal, 20)
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
    
    NavigationStack {
        ArticlesView(summary: summary)
    }
}
