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
    var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func play(text: String, language: String = "pt-BR") {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            updateState()
            return
        }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = speechRate
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar sessão de áudio: \(error)")
        }
        
        synthesizer.speak(utterance)
        updateState()
    }
    
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            updateState()
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        updateState()
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
    }
}
