//
//  SettingsView.swift
//  Shiori
//
//  Created by Henrique Hida on 03/02/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // background
            Color.bg.ignoresSafeArea()
            
            // content
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.textMuted)
                    }
                    
                    Spacer()
                    
                    Image("Isologo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundStyle(.textMuted)
                    
                    Spacer()
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundStyle(.textMuted)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // MARK: - Notícias
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Notícias")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.accentPrimary)
                            
                            ShioriSelector(
                                title: "",
                                icon: "",
                                options: SummaryStyle.allCases,
                                selection: $viewModel.selectedStyle,
                                textString: { $0.rawValue }
                            )
                            
                            ShioriSelector(
                                title: "",
                                icon: "",
                                options: SummaryDuration.allCases,
                                selection: $viewModel.selectedDuration,
                                textString: { $0.rawValue }
                            )
                            
                            ShioriSelector(
                                title: "",
                                icon: "",
                                options: viewModel.hoursOptions,
                                selection: $viewModel.selectedArriveTime,
                                textString: { viewModel.formatHour($0) }
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your interests")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.textMuted)
                            
                            SubjectsGridSettings(selectedSubjects: $viewModel.selectedSubjects)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("General")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.accentPrimary)
                            
                            ShioriSelector(
                                title: "",
                                icon: "",
                                options: Language.allCases,
                                selection: $viewModel.selectedLanguage,
                                textString: { $0.rawValue.capitalized }
                            )
                            
                            SettingsToggle(title: "Dark theme", isOn: $viewModel.isDarkMode)
                        }
                        
                        Spacer(minLength: 30)
                        
                        ShioriButton(title: "Salvar", style: .primary) {
                            Task {
                                await viewModel.saveChanges {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
    }
}

// MARK: -  SubViews
private struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.textMuted)
            }
            .toggleStyle(SwitchToggleStyle(tint: .accentPrimary))
        }
        .padding(.vertical, 5)
    }
}

private struct SubjectsGridSettings: View {
    @Binding var selectedSubjects: Set<SummarySubject>
    
    var body: some View {
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
                        } else { Color.clear }
                    }
                }
            }
        }
    }
}
