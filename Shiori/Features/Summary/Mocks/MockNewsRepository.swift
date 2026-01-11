//
//  MockNewsDatabaseRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 12/11/25.
//

import Foundation

final class MockNewsDatabaseRepository: CloudNewsRepositoryProtocol {
    func getTodayNews(preferences: NewsSummaryPreferences) async throws -> Summary {
        return Summary(
            id: "mock-1",
            title: "CNH 2026: veja como renovar a habilitação automaticamente e de graça",
            content: "Para ser considerado bom condutor, o motorista precisa cumprir os seguintes critérios: 🪪 Não ter pontos registrados na CNH nos últimos 12 meses; 🚨 Não ter infrações de trânsito registradas no documento no mesmo período; 📝 Estar cadastrado no Registro Nacional Positivo de Condutores (RNPC). Para aderir ao RNPC e ter a CNH renovada de graça, o motorista deve: Abrir o aplicativo CNH Brasil; Selecionar a opção “Condutor”; Acessar Cadastro Positivo; Tocar em Autorizar participação.",
            createdAt: try Date("2026-01-10", strategy: .iso8601),
            thumbUrl: "https://s2-g1.glbimg.com/6Z1wTV5tuVFG9LHWQMUm_ibdw1Y=/0x57:1280x777/1080x608/smart/filters:max_age(3600)/https://i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2025/G/e/Jn2qE3RrK1oXg1cKsxDg/design-sem-nome.jpg",
            sources: ["https://g1.globo.com/carros/noticia/2026/01/10/cnh-2026-veja-como-renovar-a-habilitacao-automaticamente-e-de-graca.ghtml", "https://g1.globo.com/pe/pernambuco/blog/viver-noronha/post/2026/01/10/advogada-mordida-por-tubarao-em-fernando-de-noronha-relata-senti-forte-mordida-na-perna.ghtml"],
            subjects: [.economyAndBusiness, .entertainmentAndCulture],
            type: .news
        )
    }
}
