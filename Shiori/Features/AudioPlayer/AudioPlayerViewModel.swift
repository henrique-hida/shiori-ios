//
//  AudioPlayerViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import Foundation

@Observable
final class AudioPlayerViewModel {
    var audioService: AudioServiceProtocol
    let readLaterRepo: ReadLaterRepositoryProtocol
    
    var isAudioPlaying: Bool = false
    var currentAudioId: String? = nil
    
    init(audioService: AudioServiceProtocol, readLaterRepo: ReadLaterRepositoryProtocol) {
        self.audioService = audioService
        self.readLaterRepo = readLaterRepo
        
        self.audioService.onStateChange = { [weak self] in
            self?.isAudioPlaying = self?.audioService.isPlaying ?? false
            self?.currentAudioId = self?.audioService.currentPlayingId
        }
    }
    
    func isPlaying(summaryId: String) -> Bool {
        return isAudioPlaying && currentAudioId == summaryId
    }
    
    func toggleAudio(summary: Summary, language: Language) {
        if isPlaying(summaryId: summary.id) {
            audioService.pause()
        } else {
            audioService.play(text: summary.content, id: summary.id, language: language.voiceIdentifier)
        }
    }
    
    func cleanup() {
        audioService.stop()
    }
}
