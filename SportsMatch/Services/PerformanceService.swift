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

    func defaultSummary() -> PerformanceSummary {
        let stats: [PerformanceStat] = [
            PerformanceStat(key: .availabilityMinutes, value: 0, unit: "min", label: "Minutes jouées", period: "28j"),
            PerformanceStat(key: .matchesPlayed, value: 0, unit: "matchs", label: "Matchs", period: "28j"),
            PerformanceStat(key: .impactScore, value: 0, unit: "pts", label: "Impact", period: "28j"),
            PerformanceStat(key: .maxSpeedKmh, value: 0, unit: "km/h", label: "Vitesse max", period: "28j"),
            PerformanceStat(key: .enduranceKm, value: 0, unit: "km", label: "Endurance", period: "28j"),
            PerformanceStat(key: .disciplineEvents, value: 0, unit: "ev", label: "Discipline", period: "28j")
        ]
        return PerformanceSummary(rolePrimary: nil, availabilityScore: 50, stats: stats)
    }
}


