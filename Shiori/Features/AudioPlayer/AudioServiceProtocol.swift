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
    var speechRate: Float { get set }
    
    func play(text: String, language: String)
    func pause()
    func stop()
}
