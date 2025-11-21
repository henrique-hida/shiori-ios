//
//  StartingView.swift
//  Shiori
//
//  Created by Henrique Hida on 17/11/25.
//

import SwiftUI
import SwiftData

struct StartingView: View {
    @State var viewModel = StartingViewModel()
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { geo in
            ZStack {
                // background
                Color("BgColor")
                    .ignoresSafeArea()
                
                //foreground
                VStack(spacing: 10) {
                    WaveStarting()
                        .fill(ImagePaint(image: Image("Pattern"), scale: 2))
                        .ignoresSafeArea()
                        .frame(height: geo.size.height * 0.15)
                    
                    Spacer()
                    Spacer()
                    
                    Image("Newspaper")
                    Ellipse()
                        .frame(width: 200, height: 30)
                        .foregroundStyle(EllipticalGradient(colors: [.black.opacity(0.3), .black.opacity(0.01)]))
                    
                    VStack {
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: -10) {
                                Text("Your new")
                                    .font(Font.custom("Roboto-Bold", size: 48))
                                    .foregroundStyle(Color("AccentColor"))
                                
                                Text("Newsletter")
                                    .font(Font.custom("Roboto-Bold", size: 48))
                                    .foregroundStyle(Color("AccentColor"))
                            }
                            Text("Login or register account")
                                .font(Font.custom("Roboto-Regular", size: 18))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            ShioriButton(title: "Login", style: .primary) {
                                viewModel.login()
                            }
                            
                            ShioriButton(title: "Register", style: .secondary) {
                                viewModel.register()
                            }
                        }
                    }
                    .padding(25)
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.goToSignInView) {
            SignInView()
        }
        .navigationDestination(isPresented: $viewModel.goToSignUpView) {
            SignUpView()
        }
    }
}

#Preview {
    StartingView()
}
