import Foundation

extension Summary {
    static var sampleSummaries: [SummaryData] {
        var samples: [SummaryData] = []
        
        let thumbs = [
            "https://s2-g1.glbimg.com/3XJW8mtAXe4jrnXB8B149_d4jm8=/0x0:1248x702/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2026/T/C/wTq3RuT8KAkBmPw6b8Nw/1-reuters-bloco12.jpg",
            "https://s2-g1.glbimg.com/0JXVCAyWVMO9w30Yk4qOSZUu7Ss=/0x0:4288x2848/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2026/i/u/xcqHrtSKi0P7BxeosVmw/ross-parmly-rf6ywhvkrly-unsplash.jpg",
            "https://s2-g1.glbimg.com/NqAipQiZ_MfwlOeayDsG23X-tAo=/0x0:5500x3668/1000x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2025/R/Z/I8xuVGStCgJiGF04jD4w/2025-03-15t173620z-1738905982-rc2qdda6qmye-rtrmadp-3-greenland-protest.jpg",
            "https://ichef.bbci.co.uk/news/1536/cpsprodpb/6c3d/live/0fbabe30-eec5-11f0-b5f7-49f0357294ff.jpg.webp",
            "https://ichef.bbci.co.uk/images/ic/1920xn/p0mrqq2n.jpg.webp",
            "https://ichef.bbci.co.uk/images/ic/1920xn/p0ms3mr2.jpg.webp",
            "https://static.toiimg.com/thumb/msid-126465790,imgsize-34908,width-400,resizemode-4/trump-cuban-flag.jpg"
        ]
        
        let newsData: [(title: String, content: String, subject: SummarySubject, sources: [String])] = [
            (
                "Market Surge: Tech Stocks Hit All-Time High",
                "Leading technology firms reported record-breaking quarterly earnings this morning, driving major indices to new heights despite global supply chain concerns.",
                .economyAndBusiness,
                ["Bloomberg", "Wall Street Journal"]
            ),
            (
                "The Evolution of Indie Cinema in 2026",
                "A new wave of independent filmmakers is reshaping the box office, focusing on immersive storytelling and sustainable production methods.",
                .entertainmentAndCulture,
                ["Variety", "The Hollywood Reporter"]
            ),
            (
                "Breakthrough in Renewable Energy Storage",
                "Scientists have unveiled a new solid-state battery prototype that triples the energy density of current lithium-ion models, potentially revolutionizing electric transport.",
                .healthAndScience,
                ["Nature", "Scientific American"]
            ),
            (
                "Global Summit Proposes Unified Climate Accord",
                "World leaders gathered in Brussels to debate a new framework for carbon credits, aiming for a carbon-neutral industrial sector by 2040.",
                .politic,
                ["Reuters", "BBC News"]
            ),
            (
                "Underdog Victory in the Grand Finals",
                "In a stunning upset, the league newcomers secured the championship title with a last-minute goal, ending a decade-long drought for the franchise.",
                .sports,
                ["ESPN", "The Athletic"]
            ),
            (
                "AI Integration Reaches Consumer Hardware",
                "The latest generation of smartphones features on-device neural engines capable of real-time translation and advanced photo synthesis without cloud reliance.",
                .technology,
                ["The Verge", "TechCrunch"]
            ),
            (
                "New Economic Policy Targets Inflation",
                "Central banks have announced a coordinated interest rate strategy designed to stabilize consumer prices while maintaining steady employment growth.",
                .economyAndBusiness,
                ["Financial Times", "CNBC"]
            )
        ]
        
        for i in 0..<newsData.count {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let data = newsData[i]
            
            let summary = SummaryData(
                id: "preview-news-\(i)",
                title: data.title,
                content: data.content,
                createdAt: date,
                thumbUrl: thumbs[i],
                sources: data.sources,
                subjects: [data.subject],
                type: .news
            )
            samples.append(summary)
        }
        
        return samples
    }
}
