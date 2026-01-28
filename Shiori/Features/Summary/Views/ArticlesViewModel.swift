//
//  ArticlesViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 11/01/26.
//

import Foundation

@Observable
final class ArticlesViewModel {
    let readLaterRepo: ReadLaterRepositoryProtocol
    let audioService: AudioServiceProtocol
    
    init(readLaterRepo: ReadLaterRepositoryProtocol, audioService: AudioServiceProtocol) {
        self.readLaterRepo = readLaterRepo
        self.audioService = audioService
    }
    
    func toggleAudio(text: String, language: Language) {
        if audioService.isPlaying {
            audioService.pause()
        } else {
            audioService.play(text: text, language: language.rawValue)
        }
    }
    
    func cleanup() {
        audioService.stop()
    }
}
