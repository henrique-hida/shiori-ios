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
        GeometryReader { geo in
            ZStack {
                // background
                Color(Color.backgroundShiori)
                    .ignoresSafeArea()
                
                // content
                VStack {
                    WaveSignIn()
                        .fill(ImagePaint(image: Image("Pattern"), scale: 2))
                        .ignoresSafeArea(.all, edges: .top)
                        .frame(height: geo.size.height * 0.25)
                        .padding(.bottom, 30)
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 5) {
                            Text("Welcome back")
                                .title()
                            Text("Login into your account")
                                .subTitle()
                        }
                        
                        ShioriErrorBox(errorMessage: viewModel.errorMessage, type: .error)
                            .padding(.top)
                        
                        Spacer()
                        
                        FieldsView(viewModel: viewModel)
                        
                        Spacer()
                        
                        ButtonsView(viewModel: viewModel)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
        }
        .animation(.spring, value: viewModel.errorMessage)
    }
}

// MARK: - SubViews
private struct FieldsView: View {
    @Bindable var viewModel: SignInViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ShioriField(icon: "envelope", placeholder: "Email", text: $viewModel.email, keyboard: .emailAddress)
                .textInputAutocapitalization(.never) 
                .autocorrectionDisabled()
            
            ShioriField(icon: "lock", placeholder: "Password", text: $viewModel.password, style: .secure)
                .autocorrectionDisabled()
            
            HStack {
                Spacer()
                NavigationLink(destination: SignUpView()) {
                    Text("Forgot your password?").link()
                }
            }
        }
    }
}

private struct ButtonsView: View {
    @Bindable var viewModel: SignInViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ShioriButton(title: "Login", style: .primary) {
                Task { await viewModel.login() }
            }
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .textSmall()
                NavigationLink(destination: SignUpView()) {
                    Text("Sign up").link()
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
