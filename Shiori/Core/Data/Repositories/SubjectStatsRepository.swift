//
//  SubjectStatsRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 12/01/26.
//

import Foundation
import SwiftData

@MainActor
final class SubjectStatsRepository: SubjectStatsRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func increment(subjects: [SummarySubject]) async {
        let year = Calendar.current.component(.year, from: Date())
        
        for subject in subjects {
            let id = "\(year)-\(subject.rawValue)"
            let descriptor = FetchDescriptor<SubjectStatsData>(predicate: #Predicate { $0.id == id })
            
            do {
                if let existingStat = try modelContext.fetch(descriptor).first {
                    existingStat.count += 1
                } else {
                    let newStat = SubjectStatsData(year: year, subject: subject)
                    newStat.count = 1
                    modelContext.insert(newStat)
                }
            } catch {
                print("❌ Failed to update stats: \(error)")
            }
        }
        try? modelContext.save()
    }
    
    func getYearlyStats(year: Int) async -> [(subject: SummarySubject, percentage: Double)] {
        let descriptor = FetchDescriptor<SubjectStatsData>(predicate: #Predicate { $0.year == year })
        
        guard let stats = try? modelContext.fetch(descriptor), !stats.isEmpty else {
            return []
        }
        
        let totalReads = stats.reduce(0) { $0 + $1.count }
        guard totalReads > 0 else { return [] }
        
        let result = stats.compactMap { stat -> (SummarySubject, Double)? in
            guard let subject = stat.subject else { return nil }
            let percentage = Double(stat.count) / Double(totalReads)
            return (subject, percentage)
        }
        
        return result.sorted { $0.1 > $1.1 }
    }
}
