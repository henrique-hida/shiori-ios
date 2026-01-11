//
//  ShioriField.swift
//  Shiori
//
//  Created by Henrique Hida on 19/11/25.
//

import SwiftUI

struct ShioriField: View {
    enum FieldStyleType {
        case text
        case secure
    }
    
    let icon: String
    let placeholder: String
    @Binding var text: String
    let style: FieldStyleType
    let keyboard: UIKeyboardType
    let errorMessage: String?
    
    @State private var showSecureField: Bool = false
    
    init(icon: String, placeholder: String, text: Binding<String>, style: FieldStyleType = .text, keyboard: UIKeyboardType = .default, errorMessage: String? = nil) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.style = style
        self.keyboard = keyboard
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 25)
                    .textLabelMuted()
                Group {
                    if style == .text {
                        TextField(placeholder, text: $text, prompt: Text(placeholder)
                            .foregroundStyle(Color(Color.textMutedShiori)))
                        .keyboardType(keyboard)
                    } else {
                        if !showSecureField {
                            SecureField(placeholder, text: $text, prompt: Text(placeholder).foregroundStyle(Color(Color.textMutedShiori)))
                        } else {
                            TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundStyle(Color(Color.textMutedShiori)))
                        }
                        Image(systemName: showSecureField ? "eye" : "eye.slash")
                            .textLabelMuted()
                            .onTapGesture {
                                self.showSecureField.toggle()
                            }
                    }
                }
                .tint(Color(Color.accentPrimaryShiori))
            }
            .frame(height: 20)
            .padding()
            .background(Color(Color.backgroundLightShiori))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 15)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: errorMessage)
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    
    ShioriField(icon: "envelope", placeholder: "Type your email", text: $email, style: .text, keyboard: .emailAddress, errorMessage: "Error")
    ShioriField(icon: "lock", placeholder: "Type your password", text: $password, style: .secure)
    
    Text(email)
}
