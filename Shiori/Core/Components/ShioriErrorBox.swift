//
//  ShioriErrorBox.swift
//  Shiori
//
//  Created by Henrique Hida on 22/11/25.
//

import Foundation
import SwiftUI

struct ShioriErrorBox: View {
    let errorMessage: String?
    let type: ErrorType
    
    enum ErrorType {
        case warning
        case error
        
        var color: Color {
            switch self {
            case .warning: return .orange
            case .error: return .red
            }
        }
        
        var iconName: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        if let message = errorMessage {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: type.iconName)
                    .appFont(16, weight: .bold)
                
                Text(message)
                    .appFont(14, weight: .regular)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .foregroundStyle(type.color)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(type.color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(type.color, lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ShioriErrorBox(
            errorMessage: "Incorrect email or password.",
            type: .error
        )
        
        ShioriErrorBox(
            errorMessage: "Instable connection.",
            type: .warning
        )
        
        ShioriErrorBox(
            errorMessage: nil,
            type: .error
        )
    }
    .padding()
}
