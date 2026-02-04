//
//  StartingView.swift
//  Shiori
//
//  Created by Henrique Hida on 17/11/25.
//

import SwiftUI
import SwiftData

struct StartingView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // background
                Rectangle()
                    .fill(.bg)
                    .ignoresSafeArea()
                
                //content
                VStack(spacing: 10) {
                    HeroView(availableHeight: geo.size.height)
                    
                    VStack {
                        GreetingView()
                        Spacer()
                        ButtonsView()
                    }
                    .padding(25)
                }
            }
        }
    }
}

// MARK: - SubViews
private struct HeroView: View {
    var availableHeight: CGFloat
    
    var body: some View {
        VStack {
            WaveStarting()
                .fill(ImagePaint(image: Image("Pattern"), scale: 2))
                .ignoresSafeArea()
                .frame(height: availableHeight * 0.15)
                .padding(.bottom, 30)
            
            Image("Newspaper")
            Ellipse()
                .frame(width: 200, height: 30)
                .foregroundStyle(EllipticalGradient(colors: [.black.opacity(0.3), .black.opacity(0.01)]))
        }
    }
}

private struct GreetingView: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: -10) {
                Text("Your new")
                    .title()
                
                Text("Newsletter")
                    .title()
            }
            Text("Login or register account")
                .subTitle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ButtonsView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: SignInView()) {
                RoundedRectangle(cornerRadius: 15)
                    .frame(height: 55)
                    .foregroundStyle(.accentPrimary)
                    .overlay(Text("Login")
                        .textButton()
                    )
            }
            NavigationLink(destination: SignUpView()) {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.accentPrimary, lineWidth: 2)
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                    .frame(height: 55)
                    .overlay(Text("Register")
                        .foregroundStyle(.accentPrimary)
                        .textButton()
                    )
            }
        }
    }
}

#Preview {
    StartingView()
}
