//
//  SignInView.swift
//  Shiori
//
//  Created by Henrique Hida on 10/11/25.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @Bindable var viewModel: SignInViewModel
    let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
        self.viewModel = SignInViewModel(userService: userService)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // background
                Color("BgColor")
                    .ignoresSafeArea()
                
                // foreground
                VStack(spacing: 20) {
                    WaveSignIn()
                        .fill(ImagePaint(image: Image("Pattern"), scale: 2))
                        .ignoresSafeArea(.all, edges: .top)
                        .frame(height: geo.size.height * 0.25)
                    
                    Spacer()
                    Spacer()
                    
                    VStack {
                        VStack {
                            Text("Welcome")
                                .font(Font.custom("Roboto-Bold", size: 48))
                                .foregroundStyle(Color("AccentColor"))
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
                                    .underline(color: Color("AccentColor"))
                                    .foregroundStyle(Color("AccentColor"))
                            }
                        }
                        
                        Spacer()
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
                                    .underline(color: Color("AccentColor"))
                                    .foregroundStyle(Color("AccentColor"))
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
    let container: ModelContainer = {
        let schema = Schema([AppUser.self, NewsPreferences.self, NewsPreferences.self, Summary.self])
        return try! ModelContainer(for: schema)
    }()
    SignInView(userService: DefaultUserService(authRepository: FirebaseAuthRepository(), newsDatabaseRepository: MockNewsDatabaseRepository(), modelContext: container.mainContext))
}
