//
//  AudioPlayerViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 30/01/26.
//

import Foundation
import SwiftUI

@Observable
final class AudioPlayerViewModel {
    var audioService: AudioServiceProtocol
    let readLaterRepo: ReadLaterRepositoryProtocol
    
    var isAudioPlaying: Bool = false
    var currentAudioId: String? = nil
    var progress: Double = 0.0
    var isDraggingSlider: Bool = false
    
    init(audioService: AudioServiceProtocol, readLaterRepo: ReadLaterRepositoryProtocol) {
        self.audioService = audioService
        self.readLaterRepo = readLaterRepo
        
        self.audioService.onStateChange = { [weak self] in
            guard let self = self else { return }
            self.isAudioPlaying = self.audioService.isPlaying
            self.currentAudioId = self.audioService.currentPlayingId
            
            if !self.isDraggingSlider {
                self.progress = self.audioService.progress
            }
        }
    }
    
    func seek(to value: Double) {
        audioService.seek(to: value)
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
