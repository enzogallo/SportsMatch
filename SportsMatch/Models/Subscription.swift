//
//  Subscription.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

enum SubscriptionType: String, CaseIterable, Codable {
    case free = "free"
    case playerPremium = "player_premium"
    case clubPremium = "club_premium"
    
    var displayName: String {
        switch self {
        case .free:
            return "Gratuit"
        case .playerPremium:
            return "Premium Joueur"
        case .clubPremium:
            return "Premium Club"
        }
    }
    
    var price: Double {
        switch self {
        case .free:
            return 0.0
        case .playerPremium:
            return 2.99
        case .clubPremium:
            return 9.99
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "3 candidatures par semaine",
                "Recherche de base",
                "Messagerie limitée"
            ]
        case .playerPremium:
            return [
                "Candidatures illimitées",
                "Sans publicités",
                "Mise en avant du profil",
                "Voir qui a consulté le profil",
                "Recherche avancée",
                "Notifications prioritaires"
            ]
        case .clubPremium:
            return [
                "Offres illimitées",
                "Accès complet aux candidatures",
                "Statistiques détaillées",
                "Offres sponsorisées",
                "Recherche avancée",
                "Support prioritaire"
            ]
        }
    }
}

struct Subscription: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var type: SubscriptionType
    var isActive: Bool
    var startDate: Date
    var endDate: Date?
    var autoRenew: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), userId: UUID, type: SubscriptionType = .free) {
        self.id = id
        self.userId = userId
        self.type = type
        self.isActive = true
        self.startDate = Date()
        self.endDate = nil
        self.autoRenew = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var isExpired: Bool {
        guard let endDate = endDate else { return false }
        return Date() > endDate
    }
    
    var daysRemaining: Int? {
        guard let endDate = endDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return components.day
    }
}
