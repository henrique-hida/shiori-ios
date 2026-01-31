//
//  AudioService.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

import AVFoundation
import Observation

@MainActor
@Observable
final class AVFAudioService: NSObject, AudioServiceProtocol, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var currentPlayingId: String? = nil
    var onStateChange: (() -> Void)?
    
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
            isPlaying = true
            isPaused = false
            onStateChange?()
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        do {
            try session.setActive(true)

            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language)

            currentPlayingId = id
            synthesizer.speak(utterance)
            isPlaying = true
            isPaused = false
            onStateChange?()
        } catch {
            print("Session error: \(error)")
        }
    }

    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            isPlaying = false
            isPaused = true
            onStateChange?()
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentPlayingId = nil
        isPlaying = false
        isPaused = false
        onStateChange?()
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState() }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            updateState()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState() }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in updateState() }
    }
    
    private func updateState() {
        self.isPlaying = synthesizer.isSpeaking && !synthesizer.isPaused
        self.isPaused = synthesizer.isPaused
        onStateChange?()
    }
}
