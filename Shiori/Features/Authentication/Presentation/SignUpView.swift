//
//  SignUpView.swift
//  Shiori
//
//  Created by Henrique Hida on 18/11/25.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @State private var viewModel: SignUpViewModel
    
    init() {
        _viewModel = State(wrappedValue: DependencyFactory.shared.makeSignUpViewModel())
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                //background
                Color(Color.backgroundShiori)
                    .ignoresSafeArea()
                
                if viewModel.signUpStep > 1 {
                    Button {
                        withAnimation {
                            viewModel.goToPreviousStep()
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .appFont(16, weight: .regular)
                        .foregroundStyle(Color.textMutedShiori)
                    }
                    .padding(.horizontal, 25)
                    .zIndex(1)
                    .transition(.opacity)
                }
                
                //foreground
                VStack {
                    Spacer()
                    
                    ZStack {
                        if viewModel.signUpStep == 1 {
                            FirstStepView(viewModel: viewModel, availableWidth: geo.size.width, availableHeight: geo.size.height)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading),
                                    removal: .move(edge: .leading)
                                ))
                        } else {
                            SecondStepView(viewModel: viewModel, availableWidth: geo.size.width, availableHeight: geo.size.height)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .trailing)
                                ))
                        }
                    }
                    .zIndex(10)
                    
                    VStack(spacing: 15) {
                        VStack {
                            Text("\(viewModel.signUpStep)/2").textSmall()
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 10)
                                .foregroundStyle(Color.backgroundLightShiori)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: (geo.size.width - 50) * (CGFloat(viewModel.signUpStep) * 0.5), height: 10)
                                        .foregroundStyle(Color.accentPrimaryShiori)
                                        .animation(.spring, value: viewModel.signUpStep)
                                }
                        }
                        .padding(.bottom)
                        
                        ShioriButton(title: viewModel.buttonText, style: .primary) {
                            if viewModel.signUpStep == 1 {
                                withAnimation {
                                    viewModel.goToNextStep()
                                }
                            } else {
                                Task {
                                    do {
                                        try await viewModel.signUp()
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 0) {
                            Text("Already have an account? ").textSmall()
                            Text("Sign in")
                                .link()
                                .onTapGesture {
                                    viewModel.goToSignIn()
                                }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
            .navigationDestination(isPresented: $viewModel.goToSignInView) {
                SignInView()
            }
        }
    }
}

struct FirstStepView: View {
    @Bindable var viewModel: SignUpViewModel
    let availableWidth: CGFloat
    let availableHeight: CGFloat
    
    var body: some View {
        VStack {
            VStack {
                Text("Sign up!")
                    .title()
                Text("Create your account")
                    .subTitle()
            }
            Spacer()
            
            VStack(spacing: 15) {
                ShioriField(icon: "person", placeholder: "First name", text: $viewModel.firstName)
                ShioriField(icon: "envelope", placeholder: "Email", text: $viewModel.email, keyboard: .emailAddress)
                ShioriField(icon: "lock", placeholder: "Password", text: $viewModel.password, style: .secure)
            }
            
            Spacer()
        }
        .padding(25)
        .padding(.top, availableHeight * 0.15)
    }
}

struct SecondStepView: View {
    @Bindable var viewModel: SignUpViewModel
    let availableWidth: CGFloat
    let availableHeight: CGFloat
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Customize")
                    .title()
                Text("Your news")
                    .title()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack(spacing: 15) {
                ShioriSelector(title: "Duration", icon: "clock", options: NewsDuration.allCases, selection: $viewModel.selectedDuration, textString: { $0.rawValue })
                    .zIndex(3)
                ShioriSelector(title: "Style", icon: "newspaper", options: NewsStyle.allCases, selection: $viewModel.selectedStyle, textString: { $0.rawValue })
                    .zIndex(2)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Interests")
                        .textLarge()
                    
                    let subjects = NewsSubject.allCases
                    let columnCount = 2
                    let rowCount = (subjects.count + columnCount - 1) / columnCount
                    
                    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(0..<rowCount, id: \.self) { rowIndex in
                            GridRow {
                                ForEach(0..<columnCount, id: \.self) { columnIndex in
                                    let itemIndex = (rowIndex * columnCount) + columnIndex
                                
                                    if itemIndex < subjects.count {
                                        let subject = subjects[itemIndex]
                                        
                                        ShioriCheckbox(
                                            title: subject.rawValue,
                                            icon: subject.iconName,
                                            isSelected: viewModel.selectedSubjects.contains(subject)
                                        ) {
                                            withAnimation(.snappy) {
                                                if viewModel.selectedSubjects.contains(subject) {
                                                    viewModel.selectedSubjects.remove(subject)
                                                } else {
                                                    viewModel.selectedSubjects.insert(subject)
                                                }
                                            }
                                        }
                                    } else {
                                        Color.clear
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(25)
        .padding(.top, availableHeight * 0.05)
    }
}

#Preview {
    SignUpView()
}
