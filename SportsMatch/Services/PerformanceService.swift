//
//  PerformanceService.swift
//  SportsMatch
//
//  Created by Assistant on 31/10/2025.
//

import Foundation
import Combine

final class PerformanceService: ObservableObject {
    init() {}

    func fetchSummary(forUserId userId: UUID?, token: String?, sport: String? = nil) async -> PerformanceSummary? {
        guard let userId, let token else { return nil }
        do {
            if let fromAPI = try await APIService.shared.getUserPerformance(userId: userId, token: token, sport: sport) {
                return fromAPI
            }
            return nil
        } catch {
            print("❌ fetchSummary API error: \(error.localizedDescription)")
            return nil
        }
    }

    func defaultSummary(for sport: Sport? = nil) -> PerformanceSummary {
        let stats: [PerformanceStat] = [
            PerformanceStat(key: .availabilityMinutes, value: 0, unit: "min", label: labelForMetric(.availabilityMinutes, sport: sport), period: "28j"),
            PerformanceStat(key: .matchesPlayed, value: 0, unit: "matchs", label: labelForMetric(.matchesPlayed, sport: sport), period: "28j"),
            PerformanceStat(key: .decisiveActions, value: 0, unit: "act", label: labelForMetric(.decisiveActions, sport: sport), period: "28j"),
            PerformanceStat(key: .maxSpeedKmh, value: 0, unit: "km/h", label: labelForMetric(.maxSpeedKmh, sport: sport), period: "28j"),
            PerformanceStat(key: .trainingVolumeMinPerWeek, value: 0, unit: "min/sem", label: labelForMetric(.trainingVolumeMinPerWeek, sport: sport), period: "28j"),
            PerformanceStat(key: .penaltiesEvents, value: 0, unit: "év", label: labelForMetric(.penaltiesEvents, sport: sport), period: "28j")
        ]
        return PerformanceSummary(rolePrimary: nil, level: nil, availabilityStatus: .fit, stats: stats)
    }
}


