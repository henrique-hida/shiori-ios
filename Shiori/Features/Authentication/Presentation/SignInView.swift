//
//  SignInView.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @State private var viewModel: SignInViewModel
    
    init() {
        _viewModel = State(wrappedValue: DependencyFactory.shared.makeSignInViewModel())
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { geo in
            ZStack {
                // background
                Color(Color.backgroundShiori)
                    .ignoresSafeArea()
                
                // foreground
                VStack(spacing: 20) {
                    WaveSignIn()
                        .fill(ImagePaint(image: Image("Pattern"), scale: 2))
                        .ignoresSafeArea(.all, edges: .top)
                        .frame(height: geo.size.height * 0.25)
                    
                    Spacer()
                    
                    VStack {
                        VStack {
                            Text("Welcome")
                                .font(Font.custom("Roboto-Bold", size: 48))
                                .foregroundStyle(Color(Color.accentPrimaryShiori))
                            Text("Login into you account")
                                .font(Font.custom("Roboto-Regular", size: 20))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 15) {
                            ShioriField(icon: "envelope", placeholder: "Email", text: $viewModel.email, style: .text, keyboard: .emailAddress)
                            
                            ShioriField(icon: "lock", placeholder: "Password", text: $viewModel.password, style: .secure)
                            
                            HStack {
                                Spacer()
                                Text("Forgot your password?")
                                    .font(.callout)
                                    .underline(color: Color(Color.accentPrimaryShiori))
                                    .foregroundStyle(Color(Color.accentPrimaryShiori))
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 15) {
                            ShioriButton(title: "Login", style: .primary) {
                                Task {
                                    do {
                                        try await viewModel.login()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            
                            HStack(spacing: 3) {
                                Text("Don't have an account?")
                                    .font(Font.custom("Roboto", size: 16))
                                Text("Sign in")
                                    .font(Font.custom("Roboto", size: 16))
                                    .underline(color: Color(Color.accentPrimaryShiori))
                                    .foregroundStyle(Color(Color.accentPrimaryShiori))
                                    .onTapGesture {
                                        viewModel.goToSignUp()
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
