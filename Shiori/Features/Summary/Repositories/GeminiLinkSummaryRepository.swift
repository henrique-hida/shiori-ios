//
//  GeminiLinkSummaryRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation

class GeminiLinkSummaryRepository: LinkSummaryRepositoryProtocol {
    private let apiKey: String
    private let modelName: String
    
    init(apiKey: String, modelName: String = "gemini-2.5-flash") {
        self.apiKey = apiKey
        self.modelName = modelName
    }
    
    
    func summarizeLink(url: URL, style: SummaryStyle, duration: SummaryDuration) async throws -> Summary {
        let pageData = try await fetchPageContent(from: url)
        let currentLanguage: Language = Language.currentSystemLanguage
        
        let prompt = buildPrompt(
            text: pageData.cleanedText,
            url: url.absoluteString,
            style: style,
            duration: duration,
            language: currentLanguage
        )
        
        let generatedData = try await sendRequestToGemini(prompt: prompt)
        let finalThumbUrl = pageData.thumbUrl ?? ""
        
        return Summary(
            id: UUID().uuidString,
            title: generatedData.title,
            content: generatedData.content,
            createdAt: Date(),
            thumbUrl: finalThumbUrl,
            sources: [url.absoluteString],
            subjects: [generatedData.subject],
            type: .link
        )
    }
    
    
    private func sendRequestToGemini(prompt: String) async throws -> GeminiResponse {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiRepo", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            throw NSError(domain: "GeminiRepo", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(errorMsg)"])
        }
        
        let apiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)
        
        guard let text = apiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "GeminiRepo", code: 500, userInfo: [NSLocalizedDescriptionKey: "Empty response from Gemini"])
        }
        
        return try parseCleanJSON(text)
    }
    
    
    private struct GeminiAPIResponse: Decodable {
        struct Candidate: Decodable {
            struct Content: Decodable {
                struct Part: Decodable {
                    let text: String
                }
                let parts: [Part]
            }
            let content: Content
        }
        let candidates: [Candidate]
    }
    
    private struct GeminiResponse: Decodable {
        let title: String
        let content: String
        let subject: SummarySubject
    }
    
    private func parseCleanJSON(_ text: String) throws -> GeminiResponse {
        let cleanText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanText.data(using: .utf8) else {
            throw NSError(domain: "GeminiRepo", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode cleaned text"])
        }
        
        return try JSONDecoder().decode(GeminiResponse.self, from: data)
    }
    
    private struct PageData {
        let cleanedText: String
        let thumbUrl: String?
    }
    
    private func fetchPageContent(from url: URL) async throws -> PageData {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "GeminiRepo", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not decode HTML"])
        }
        
        var thumbUrl: String? = nil
        if let range = htmlString.range(of: "<meta property=\"og:image\" content=\"") {
            let substring = htmlString[range.upperBound...]
            if let endRange = substring.range(of: "\"") {
                thumbUrl = String(substring[..<endRange.lowerBound])
            }
        }
        
        var text = htmlString
        text = text.replacingOccurrences(of: "<script[\\s\\S]*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[\\s\\S]*?</style>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        let maxLength = 15000
        if text.count > maxLength {
            text = String(text.prefix(maxLength))
        }
        
        return PageData(cleanedText: text.trimmingCharacters(in: .whitespacesAndNewlines), thumbUrl: thumbUrl)
    }
    
    private func buildPrompt(text: String, url: String, style: SummaryStyle, duration: SummaryDuration, language: Language) -> String {
        let validCategories = SummarySubject.allCases
            .map { $0.rawValue }
            .joined(separator: ", ")
        
        return """
            Act as a news summarizer.
            INPUT TEXT:
            \"\"\"
            \(text)
            \"\"\"
            
            INSTRUCTIONS:
            1. Summarize the text above.
            2. Style: \(style.rawValue).
            3. Length: \(duration.rawValue).
            4. Language: \(language.rawValue).
            
            5. SUBJECT CLASSIFICATION (CRITICAL):
            Classify the text strictly as ONE of the following exact categories:
            [ \(validCategories) ]
            
            IMPORTANT: The "subject" field in the JSON output MUST match one of the categories above exactly, character for character.
            
            6. Length Definition: "fast" = 50 words max, "standard" = 100 words, "deep" = 250 words.
            
            OUTPUT JSON:
            {
                "title": "Headline",
                "content": "Summary",
                "subject": "Category (Exact Match)"
            }
            """
    }
}
