//
//  AudioServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

import Foundation

protocol AudioServiceProtocol {
    var isPlaying: Bool { get }
    var isPaused: Bool { get }
    var currentPlayingId: String? { get }
    var progress: Double { get }
    var onStateChange: (() -> Void)? { get set }
    
    func play(text: String, id: String, language: String)
    func pause()
    func stop()
    func seek(to percentage: Double)
}
