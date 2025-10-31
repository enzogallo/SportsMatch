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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("CV sportif")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                AvailabilityBadge(score: summary.availabilityScore)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(summary.stats, id: \.self) { stat in
                    PerformanceStatCard(
                        title: stat.label,
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

private struct AvailabilityBadge: View {
    let score: Int
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "figure.run")
                .font(.caption2)
            Text("\(score)/100")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(scoreColor)
        .clipShape(Capsule())
    }
    private var scoreColor: Color {
        switch score {
        case 0..<50: return .error
        case 50..<75: return .warning
        default: return .success
        }
    }
}


