//
//  PerformanceStats.swift
//  SportsMatch
//
//  Created by Assistant on 31/10/2025.
//

import SwiftUI

struct PerformanceStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PerformanceStatGrid: View {
    let summary: PerformanceSummary
    var sport: Sport? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("CV sportif")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                AvailabilityStatusBadge(status: summary.availabilityStatus)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(summary.stats, id: \.self) { stat in
                    PerformanceStatCard(
                        title: labelForMetric(stat.key, sport: sport),
                        value: formattedValue(stat),
                        subtitle: stat.period
                    )
                }
            }
        }
        .padding(20)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formattedValue(_ stat: PerformanceStat) -> String {
        if stat.unit.isEmpty { return String(format: "%g", stat.value) }
        if stat.key == .maxSpeedKmh {
            return String(format: "%.1f %@", stat.value, stat.unit)
        }
        if floor(stat.value) == stat.value {
            return "\(Int(stat.value)) \(stat.unit)"
        }
        return String(format: "%.1f %@", stat.value, stat.unit)
    }
}

    private struct AvailabilityStatusBadge: View {
    let status: AvailabilityStatus
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color)
        .clipShape(Capsule())
    }
    private var label: String {
        switch status {
        case .fit: return "Apte"
        case .returning: return "Retour"
        case .injured: return "Blessé"
        }
    }
    private var icon: String {
        switch status {
        case .fit: return "figure.run"
        case .returning: return "arrow.counterclockwise"
        case .injured: return "bandage.fill"
        }
    }
    private var color: Color {
        switch status {
        case .fit: return .success
        case .returning: return .warning
        case .injured: return .error
        }
    }
}


