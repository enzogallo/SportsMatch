//
//  Performance.swift
//  SportsMatch
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

enum PerformanceMetricKey: String, Codable, CaseIterable, Hashable {
    case availabilityMinutes      // minutes jouées (28j)
    case matchesPlayed            // matchs/épreuves (28j)
    case decisiveActions          // actions décisives (28j)
    case maxSpeedKmh              // vitesse max / perf clé
    case trainingVolumeMinPerWeek // volume d'entraînement (min/sem)
    case penaltiesEvents          // pénalités/fautes (28j)
}

struct PerformanceStat: Codable, Hashable {
    let key: PerformanceMetricKey
    let value: Double
    let unit: String
    let label: String // label affichage (universel/mappé)
    let period: String // ex: "28j", "12m"
}

enum AvailabilityStatus: String, Codable, CaseIterable, Hashable { case fit, returning, injured }

struct PerformanceSummary: Codable, Hashable {
    let rolePrimary: String?
    let level: String?
    let availabilityStatus: AvailabilityStatus
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


