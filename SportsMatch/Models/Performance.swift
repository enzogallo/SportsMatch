//
//  Performance.swift
//  SportsMatch
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

enum PerformanceMetricKey: String, Codable, CaseIterable, Hashable {
    case availabilityMinutes // minutes jouées récentes
    case matchesPlayed       // nombre de matchs
    case impactScore         // score agrégé (buts/assists/arrêts... mappé par sport)
    case maxSpeedKmh         // vitesse max
    case enduranceKm         // distance récente
    case disciplineEvents    // fautes/cartons/turnovers
}

struct PerformanceStat: Codable, Hashable {
    let key: PerformanceMetricKey
    let value: Double
    let unit: String
    let label: String // label affichage (universel/mappé)
    let period: String // ex: "28j", "12m"
}

struct PerformanceSummary: Codable, Hashable {
    let rolePrimary: String?
    let availabilityScore: Int // 0-100
    let stats: [PerformanceStat]
}

struct PerformanceSession: Codable, Hashable, Identifiable {
    enum SessionType: String, Codable { case match, training, test }
    let id: UUID
    let date: Date
    let type: SessionType
    let durationMinutes: Int
    let rpe: Int?
    let source: String? // manual, healthkit, other
}

struct PerformanceTest: Codable, Hashable, Identifiable {
    enum TestType: String, Codable { case sprint30m, sprint10m, yoyo, cooper, cmj, agilityT }
    let id: UUID
    let date: Date
    let type: TestType
    let value: Double
    let unit: String
    let verified: Bool
}


