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
                                .title()
                            Text("Login into you account")
                                .subTitle()
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 15) {
                            ShioriField(icon: "envelope", placeholder: "Email", text: $viewModel.email, keyboard: .emailAddress)
                            
                            ShioriField(icon: "lock", placeholder: "Password", text: $viewModel.password, style: .secure)
                            
                            HStack {
                                Spacer()
                                Text("Forgot your password?")
                                    .link()
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
                            
                            HStack(spacing: 0) {
                                Text("Don't have an account? ")
                                    .textSmall()
                                Text("Sign up")
                                    .link()
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
        .navigationDestination(isPresented: $viewModel.goToSignUpView) {
            SignUpView()
        }
    }
}

#Preview {
    SignInView()
}
