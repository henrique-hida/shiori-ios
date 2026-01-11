//
//  ShioriCheckbox.swift
//  Shiori
//
//  Created by Henrique Hida on 21/11/25.
//

import Foundation
import SwiftUI

struct ShioriCheckbox: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? Color.textButtonShiori : Color.textMutedShiori)
                    .frame(width: 20)
                    .textLabelMuted()
                
                Text(title.capitalized)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(isSelected ? Color.textButtonShiori : Color.textMutedShiori)
                    .textLabelMuted()
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.textButtonShiori : Color.textMutedShiori)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.accentPrimaryShiori : Color.backgroundLightShiori)
                    .shadow(color: .black.opacity(0.05), radius: 1, y: 3)
            )
        }
    }
}

#Preview {
    @Previewable @State var selectedSubjects: Set<SummarySubject> = []
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    ZStack {
        Color.backgroundShiori
            .ignoresSafeArea()
        
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(SummarySubject.allCases, id: \.self) { subject in
                ShioriCheckbox(
                    title: subject.rawValue,
                    icon: subject.iconName,
                    isSelected: selectedSubjects.contains(subject)
                ) {
                    withAnimation(.snappy) {
                        if selectedSubjects.contains(subject) {
                            selectedSubjects.remove(subject)
                        } else {
                            selectedSubjects.insert(subject)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
