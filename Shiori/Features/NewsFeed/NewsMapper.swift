//
//  NewsMapper.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation

struct NewsMapper {
    static func mapToDTO(from preferences: NewsPreferences) -> NewsRequestBody {
        return NewsRequestBody(
            newsDuration: preferences.newsDuration,
            newsStyle: preferences.newsStyle,
            newsSubjects: preferences.newsSubjects,
            newsLanguage: preferences.newsLanguage,
            newsArriveTime: preferences.newsArriveTime
        )
    }
    
    static func mapToEntity(from dto: NewsResponseDTO) -> News {
        return News(
            title: dto.title ?? "No Title",
            content: dto.content ?? "No Content",
            thumbLink: dto.thumbLink ?? "",
            date: dto.date ?? Date(),
            articleLinks: dto.articleLinks ?? [],
            wasRead: dto.wasRead ?? false
        )
    }
}
