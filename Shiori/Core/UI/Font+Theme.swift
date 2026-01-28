//
//  Font+Theme.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftUI

private func getFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .black:        return "Roboto-Black"
    case .heavy:        return "Roboto-ExtraBold"
    case .bold:         return "Roboto-Bold"
    case .semibold:     return "Roboto-SemiBold"
    case .regular:      return "Roboto-Regular"
    case .medium:       return "Roboto-Medium"
    case .light:        return "Roboto-Light"
    case .thin:         return "Roboto-Thin"
    default:            return "Roboto-Regular"
    }
}

struct AppFontFixedModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        let fontName = getFontName(for: weight)
        return content
            .font(Font.custom(fontName, size: size))
    }
}

extension View {
    func appFont(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(AppFontFixedModifier(size: size, weight: weight))
    }
    
    func textSmall() -> some View {
        self.appFont(14, weight: .regular)
            .foregroundStyle(.textMuted)
    }
    
    func textMedium() -> some View {
        self.appFont(14, weight: .regular)
            .foregroundStyle(.textPrimary)
    }
    
    func textLabelMuted() -> some View {
        self.appFont(16, weight: .regular)
            .foregroundStyle(.textMuted)
    }
    
    func textLabelSelected() -> some View {
        self.appFont(16, weight: .regular)
            .foregroundStyle(.textPrimary)
    }
    
    func textLarge() -> some View {
        self.appFont(16, weight: .bold)
            .foregroundStyle(.textPrimary)
    }
    
    func newsDate() -> some View {
        self.appFont(24, weight: .bold)
            .foregroundStyle(.textButton)
    }
    
    func title() -> some View {
        self.appFont(48, weight: .bold)
            .foregroundStyle(.accentPrimary)
    }
    
    func subTitle() -> some View {
        self.appFont(20, weight: .regular)
            .foregroundStyle(.textMuted)
    }
    
    func textButton() -> some View {
        self.appFont(16, weight: .bold)
            .foregroundStyle(.textButton)
    }
    
    func link() -> some View {
        self.appFont(14, weight: .regular)
            .foregroundStyle(.accentPrimary)
            .underline(color: .accentPrimary)
    }
    
}
