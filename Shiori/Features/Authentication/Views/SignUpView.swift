//
//  SignUpView.swift
//  Shiori
//
//  Created by Henrique Hida on 18/11/25.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var viewModel: SignUpViewModel
    
    init() {
        _viewModel = State(wrappedValue: DependencyFactory.shared.makeSignUpViewModel())
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // background
                Color(Color.backgroundShiori)
                    .ignoresSafeArea()
                
                // content
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            if viewModel.signUpStep > 1 {
                                BackButton {
                                    withAnimation { viewModel.goToPreviousStep() }
                                }
                            } else {
                                Color.clear.frame(height: 44)
                            }
                            
                            VStack(spacing: 20) {
                                TitleView(step: viewModel.signUpStep)
                                    .padding(.top, 50)
                                
                                StepContentView(viewModel: viewModel, width: geo.size.width)
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 25)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack(spacing: 20) {
                        ProgressBar(currentStep: viewModel.signUpStep, totalSteps: 2, maxWidth: geo.size.width)
                        SignUpButtonsView(viewModel: viewModel)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                    .padding(.top, 10)
                    .background(Color.backgroundShiori)
                }
            }
        }
        .onChange(of: viewModel.registeredUser) { _, newUser in
            if let user = newUser {
                sessionManager.signIn(with: user)
            }
        }
        .animation(.spring, value: viewModel.errorMessage)
        .animation(.spring, value: viewModel.signUpStep)
    }
}

// MARK: - SubViews

private struct BackButton: View {
    let action: () -> Void
    var body: some View {
        HStack {
            Button(action: action) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundStyle(Color.textMutedShiori)
                .appFont(16, weight: .regular)
            }
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.top, 10)
    }
}

private struct TitleView: View {
    let step: Int
    var body: some View {
        VStack(spacing: 5) {
            Text(step == 1 ? "Sign up!" : "Customize")
                .title()
            Text(step == 1 ? "Create your account" : "Your news preferences")
                .subTitle()
        }
        .multilineTextAlignment(.center)
    }
}

private struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let maxWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(currentStep)/\(totalSteps)").textSmall()
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 6)
                    .foregroundStyle(Color.backgroundLightShiori)
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: (maxWidth - 50) * (CGFloat(currentStep) / CGFloat(totalSteps)), height: 6)
                    .foregroundStyle(Color.accentPrimaryShiori)
            }
            .frame(height: 6)
        }
        .padding(.bottom, 10)
    }
}

private struct StepContentView: View {
    @Bindable var viewModel: SignUpViewModel
    let width: CGFloat
    
    var body: some View {
        ZStack {
            if viewModel.signUpStep == 1 {
                FirstStepView(viewModel: viewModel)
                    .padding(.vertical, 50)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                SecondStepView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }
}

private struct SignUpButtonsView: View {
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ShioriButton(title: viewModel.buttonText, style: .primary) {
                Task {
                    await viewModel.handleButtonPress()
                }
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.7 : 1)
            
            HStack(spacing: 0) {
                Text("Already have an account? ").textSmall()
                NavigationLink(destination: SignInView()) {
                    Text("Sign in").link()
                }
            }
        }
    }
}

// MARK: - Step Views

struct FirstStepView: View {
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ShioriErrorBox(errorMessage: viewModel.errorMessage, type: .error)
            
            ShioriField(
                icon: "person",
                placeholder: "First name",
                text: $viewModel.firstName,
                errorMessage: viewModel.firstNameErrorMessage
            )
            
            ShioriField(
                icon: "envelope",
                placeholder: "Email",
                text: $viewModel.email,
                keyboard: .emailAddress,
                errorMessage: viewModel.emailErrorMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            ShioriField(
                icon: "lock",
                placeholder: "Password",
                text: $viewModel.password,
                style: .secure,
                errorMessage: viewModel.passwordErrorMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }
}

struct SecondStepView: View {
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ShioriSelector(
                title: "Duration",
                icon: "clock",
                options: SummaryDuration.allCases,
                selection: $viewModel.selectedDuration,
                textString: { $0.rawValue }
            )
            .zIndex(2)
            
            ShioriSelector(
                title: "Style",
                icon: "newspaper",
                options: SummaryStyle.allCases,
                selection: $viewModel.selectedStyle,
                textString: { $0.rawValue }
            )
            .zIndex(1)
            SubjectsGrid(viewModel: viewModel)
        }
    }
}

struct SubjectsGrid: View {
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interests").textLarge()
            
            let subjects = SummarySubject.allCases
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

#Preview {
    let sessionManager = DependencyFactory.shared.makeSessionManager()
    
    SignUpView()
        .environment(sessionManager)
}
