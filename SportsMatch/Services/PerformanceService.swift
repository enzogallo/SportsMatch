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

    func fetchSummary(forUserId userId: UUID?, token: String?) async -> PerformanceSummary? {
        guard let userId, let token else { return nil }
        do {
            if let fromAPI = try await APIService.shared.getUserPerformance(userId: userId, token: token) {
                return fromAPI
            }
            return nil
        } catch {
            print("❌ fetchSummary API error: \(error.localizedDescription)")
            return nil
        }
    }
}


