//
//  ArticlesView.swift
//  Shiori
//
//  Created by Henrique Hida on 09/01/26.
//

import SwiftUI

struct ArticlesView: View {
    var article: News
        
    var body: some View {
        ZStack {
            // background
            
            // content
            ScrollView {
                Text(article.content)
                    .textSmall()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            AudioPlayer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "arrow.left")
                    .foregroundStyle(Color.textMuted)
            }
            
            ToolbarItem(placement: .principal) {
                Text(article.date.formatted(.dateTime.day().month().year()))
                    .bold()
                    .subTitle()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Menu tapped")
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AudioPlayer: View {
    var isPlaying: Bool = false
    @State private var progress: Double = 0.3
    
    var body: some View {
        VStack(spacing: 20) {
            Slider(value: $progress)
                .tint(Color.accent)
            
            HStack(spacing: 30) {
                Image(systemName: "10.arrow.trianglehead.counterclockwise")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accent)
                
                Circle()
                    .overlay(
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.bg)
                    )
                    .foregroundStyle(Color.accent)
                    .frame(width: 50)
                
                Image(systemName: "10.arrow.trianglehead.clockwise")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accent)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let date = Date()
    let article = News(
        id: "id-1",
        category: "technology",
        content: "Lorem Ipsum",
        date: date,
        tone: "Informal",
        wasRead: false
    )
    
    NavigationStack {
        ArticlesView(article: article)
    }
}
