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
    
    init(readLaterRepo: ReadLaterRepositoryProtocol) {
        self.readLaterRepo = readLaterRepo
    }
}
