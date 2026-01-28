//
//  UnrealAudioService.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

import Foundation
import AVFoundation
import Observation

private struct UnrealRequest: Codable {
    let Text: String
    let VoiceId: String
    let Bitrate: String
    let Speed: String
    let Pitch: String
    let Codec: String
}

private struct UnrealResponse: Codable {
    let OutputUri: String?
}


@MainActor
@Observable
final class UnrealAudioService: NSObject, AudioServiceProtocol, AVAudioPlayerDelegate {
    private let apiKey: String
    
    init (apiKey: String) {
        self.apiKey = apiKey
    }
    
    var isPlaying: Bool = false
    var isPaused: Bool = false
    
    var speechRate: Float = 1.0 {
        didSet {
            audioPlayer?.rate = speechRate
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    private var currentTask: Task<Void, Never>?
    private let defaultVoice = "Scarlett"
    
    func play(text: String, language: String) {
        if isPaused, let player = audioPlayer {
            player.play()
            updateState()
            return
        }
        
        stop()
        currentTask = Task {
            do {
                let audioData = try await fetchAudio(text: text)
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.delegate = self
                audioPlayer?.enableRate = true
                audioPlayer?.rate = speechRate
                audioPlayer?.prepareToPlay()
                
                audioPlayer?.play()
                updateState()
                
            } catch {
                print("❌ Erro no Unreal Speech: \(error.localizedDescription)")
                stop()
            }
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        updateState()
    }
    
    func stop() {
        currentTask?.cancel()
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        updateState()
    }
    
    private func fetchAudio(text: String) async throws -> Data {
        let isShortText = text.count <= 1000
        let endpoint = isShortText ? "https://api.v8.unrealspeech.com/stream" : "https://api.v8.unrealspeech.com/speech"
        
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }
        
        let requestBody = UnrealRequest(
            Text: text,
            VoiceId: defaultVoice,
            Bitrate: "192k",
            Speed: "0",
            Pitch: "1",
            Codec: "libmp3lame"
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorText = String(data: data, encoding: .utf8) {
                print("API Error Body: \(errorText)")
            }
            throw URLError(.badServerResponse)
        }
        
        if isShortText {
            return data
        }
        
        let jsonResponse = try JSONDecoder().decode(UnrealResponse.self, from: data)
        guard let audioUrlString = jsonResponse.OutputUri,
              let audioUrl = URL(string: audioUrlString) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let (audioData, _) = try await URLSession.shared.data(from: audioUrl)
        return audioData
    }
    
    private func updateState() {
        if let player = audioPlayer {
            self.isPlaying = player.isPlaying
            self.isPaused = !player.isPlaying && player.currentTime > 0
        } else {
            self.isPlaying = false
            self.isPaused = false
        }
    }
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in stop() }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in stop() }
    }
}
