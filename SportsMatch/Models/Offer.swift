//
//  Offer.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

enum OfferType: String, CaseIterable, Codable {
    case recruitment = "recruitment"
    case tournament = "tournament"
    case training = "training"
    case replacement = "replacement"
    
    var displayName: String {
        switch self {
        case .recruitment:
            return "Recrutement"
        case .tournament:
            return "Tournoi"
        case .training:
            return "Entraînement"
        case .replacement:
            return "Remplaçant"
        }
    }
}

enum OfferStatus: String, CaseIterable, Codable {
    case active = "active"
    case paused = "paused"
    case closed = "closed"
    case filled = "filled"
    
    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .paused:
            return "En pause"
        case .closed:
            return "Fermée"
        case .filled:
            return "Pourvue"
        }
    }
}

struct Offer: Identifiable, Codable {
    let id: UUID
    let clubId: UUID
    var title: String
    var description: String
    var sport: Sport
    var position: String?
    var level: SkillLevel?
    var type: OfferType
    var location: String
    var city: String
    var ageRange: AgeRange?
    var isUrgent: Bool
    var status: OfferStatus
    var createdAt: Date
    var updatedAt: Date
    var expiresAt: Date?
    var maxApplications: Int?
    var currentApplications: Int
    
    init(id: UUID = UUID(), clubId: UUID, title: String, description: String, sport: Sport, location: String, city: String) {
        self.id = id
        self.clubId = clubId
        self.title = title
        self.description = description
        self.sport = sport
        self.location = location
        self.city = city
        self.type = .recruitment
        self.isUrgent = false
        self.status = .active
        self.createdAt = Date()
        self.updatedAt = Date()
        self.currentApplications = 0
    }
}

struct AgeRange: Codable {
    let min: Int
    let max: Int
    
    var displayName: String {
        return "\(min) - \(max) ans"
    }
}

struct Application: Identifiable, Codable {
    let id: UUID
    let offerId: UUID
    let playerId: UUID
    var message: String?
    var status: ApplicationStatus
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), offerId: UUID, playerId: UUID, message: String? = nil) {
        self.id = id
        self.offerId = offerId
        self.playerId = playerId
        self.message = message
        self.status = .pending
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ApplicationStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case withdrawn = "withdrawn"
    
    var displayName: String {
        switch self {
        case .pending:
            return "En attente"
        case .accepted:
            return "Acceptée"
        case .rejected:
            return "Refusée"
        case .withdrawn:
            return "Retirée"
        }
    }
}
