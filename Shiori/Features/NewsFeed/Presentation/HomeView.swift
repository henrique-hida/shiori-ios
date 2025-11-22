//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let user: AppUser
    
    init(user: AppUser) {
        self.user = user
    }
        
    var body: some View {
        Text("Home View")
    }
}

#Preview {
    let container = DatabaseProvider.preview.container
    let context = container.mainContext
    
    let dummyNews = News(
        title: "Welcome",
        content: "Content",
        thumbLink: "",
        date: Date(),
        articleLinks: [],
        wasRead: false
    )
    
    let dummyPrefs = NewsPreferences(
        newsDuration: .fast,
        newsStyle: .informal,
        newsSubjects: [],
        newsLanguage: .english,
        newsArriveTime: 8
    )
    
    let user = AppUser(
        id: "preview_id",
        firstName: "Preview User",
        isPremium: true,
        language: .english,
        schema: .system,
        todayBackupNews: dummyNews,
        newsPreferences: dummyPrefs
    )
    
    context.insert(user)
    
    return HomeView(user: user)
        .modelContainer(container)
}
