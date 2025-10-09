//
//  Colors.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

extension Color {
    // Couleurs principales de SportsMatch
    static let primaryBlue = Color(hex: "#0066FF")
    static let secondaryGreen = Color(hex: "#00C27A")
    
    // Couleurs neutres
    static let background = Color(hex: "#F8F9FA")
    static let surface = Color.white
    static let surfaceSecondary = Color(hex: "#F1F3F4")
    
    // Couleurs de texte
    static let textPrimary = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#6B7280")
    static let textTertiary = Color(hex: "#9CA3AF")
    
    // Couleurs d'état
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    static let info = Color(hex: "#3B82F6")
    
    // Couleurs de statut
    static let statusActive = Color(hex: "#10B981")
    static let statusPending = Color(hex: "#F59E0B")
    static let statusInactive = Color(hex: "#6B7280")
    
    // Couleurs de niveau
    static let levelBeginner = Color(hex: "#10B981")
    static let levelIntermediate = Color(hex: "#3B82F6")
    static let levelAdvanced = Color(hex: "#8B5CF6")
    static let levelExpert = Color(hex: "#F59E0B")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
