//
//  CustomButton.swift
//  Shiori
//
//  Created by Henrique Hida on 18/11/25.
//
import SwiftUI

struct ShioriButton: View {
    enum ButtonStyleType {
        case primary
        case secondary
    }
    
    let title: String
    let style: ButtonStyleType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if style == .primary {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.accentPrimary)
                        .overlay(buttonText)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.accentPrimary, lineWidth: 2)
                        .contentShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(buttonText)
                }
            }
            .frame(height: 55)
        }
        .buttonStyle(.plain)
    }
    
    private var buttonText: some View {
        Text(title)
            .font(Font.custom("Roboto-Bold", size: 16))
            .foregroundStyle(style == .primary ? .textButton : .accentPrimary)
    }
}

#Preview {
    VStack(spacing: 20) {
        ShioriButton(title: "Login", style: .primary) {}
        ShioriButton(title: "Register", style: .secondary) {}
    }
    .padding()
}
