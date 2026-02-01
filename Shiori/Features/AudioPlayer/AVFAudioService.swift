//
//  AudioService.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

// AVFAudioService.swift
import AVFoundation
import Observation

@MainActor
@Observable
final class AVFAudioService: NSObject, AudioServiceProtocol, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var currentPlayingId: String? = nil
    var progress: Double = 0.0
    var onStateChange: (() -> Void)?
    
    private var fullText: String = ""
    private var currentLanguage: String = "en-US"
    private var playedOffset: Int = 0
    
    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }
    
    func play(text: String, id: String, language: String = "en-US") {
        let session = AVAudioSession.sharedInstance()

        if synthesizer.isPaused && currentPlayingId == id {
            try? session.setActive(true)
            synthesizer.continueSpeaking()
            updateState(playing: true, paused: false)
            return
        }

        if currentPlayingId != id {
            stop()
            fullText = text
            currentLanguage = language
            playedOffset = 0
            progress = 0.0
        }

        startSpeaking(text: text, id: id, language: language)
    }

    private func startSpeaking(text: String, id: String, language: String) {
        let session = AVAudioSession.sharedInstance()
        do {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            try session.setActive(true)

            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            utterance.postUtteranceDelay = 0.1

            currentPlayingId = id
            synthesizer.speak(utterance)
            updateState(playing: true, paused: false)
        } catch {
            print("Session error: \(error)")
        }
    }
    
    func seek(to percentage: Double) {
        guard !fullText.isEmpty, let id = currentPlayingId else { return }
        
        let utf16Count = fullText.utf16.count
        let newIndex = Int(Double(utf16Count) * percentage)
        let clampedIndex = max(0, min(newIndex, utf16Count - 1))
        let rawIndex = fullText.utf16.index(fullText.utf16.startIndex, offsetBy: clampedIndex)
        let alignedIndex = fullText.rangeOfComposedCharacterSequence(at: rawIndex).lowerBound
        
        playedOffset = fullText.utf16.distance(from: fullText.utf16.startIndex, to: alignedIndex)
        self.progress = percentage
        self.onStateChange?()
        let textSuffix = String(fullText[alignedIndex...])
        
        startSpeaking(text: textSuffix, id: id, language: currentLanguage)
    }

    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            updateState(playing: false, paused: true)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentPlayingId = nil
        fullText = ""
        playedOffset = 0
        progress = 0.0
        updateState(playing: false, paused: false)
    }
    
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard !fullText.isEmpty else { return }
            let totalLength = fullText.utf16.count
            let currentPosition = playedOffset + characterRange.location + characterRange.length
            
            if totalLength > 0 {
                self.progress = Double(currentPosition) / Double(totalLength)
                self.onStateChange?()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if progress > 0.95 {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                updateState(playing: false, paused: false)
                progress = 1.0
            }
        }
    }
    
    private func updateState(playing: Bool, paused: Bool) {
        self.isPlaying = playing
        self.isPaused = paused
        onStateChange?()
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState(playing: true, paused: false) }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState(playing: false, paused: true) }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState(playing: true, paused: false) }
    }
}
