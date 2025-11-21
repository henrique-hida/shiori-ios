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
        Text("Hello, World!")
    }
}

#Preview {
    SignUpView()
}
