//
//  ShioriSelector.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftUI

struct ShioriSelector<T: Hashable>: View {
    let title: String
    let icon: String
    let options: [T]
    @Binding var selection: T
    
    var textString: (T) -> String = { "\($0)" }
    
    @State private var isExpanded = false
    @State private var buttonHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .textLarge()
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .textLabelMuted()
                        .frame(width: 20)
                    
                    Text(textString(selection).capitalized)
                        .textLabelSelected()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .textLabelMuted()
                }
                .padding()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ButtonHeightKey.self, value: geo.size.height)
                    }
                )
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(Color.backgroundLightShiori)
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
                )
            }
            .onPreferenceChange(ButtonHeightKey.self) { buttonHeight = $0 }
            .background(alignment: .top) {
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                withAnimation(.snappy) {
                                    selection = option
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(textString(option).capitalized)
                                        .foregroundStyle(selection == option ? Color.accentColor : Color.textPrimaryShiori)
                                        .textLabelSelected()
                                    Spacer()
                                    if selection == option {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.accentColor)
                                            .textLabelSelected()
                                    }
                                }
                                .padding()
                            }
                            
                            if option != options.last {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.backgroundLightShiori)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    .offset(y: buttonHeight + 5)
                }
            }
            .zIndex(10)
        }
    }
}

struct ButtonHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    @Previewable @State var selectedDuration: NewsDuration = .standard
    ZStack(alignment: .top) {
        Color(Color.backgroundShiori).ignoresSafeArea()
        
        VStack(spacing: 20) {
            Spacer()
            ShioriSelector(
                title: "Select your news duration",
                icon: "clock",
                options: NewsDuration.allCases,
                selection: $selectedDuration,
                textString: { $0.rawValue }
            )
            Spacer()
        }
        .padding()
    }
}
