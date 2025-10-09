//
//  User.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

enum UserRole: String, CaseIterable, Codable {
    case player = "player"
    case club = "club"
    
    var displayName: String {
        switch self {
        case .player:
            return "Joueur"
        case .club:
            return "Club"
        }
    }
}

enum UserStatus: String, CaseIterable, Codable {
    case available = "available"
    case busy = "busy"
    case looking = "looking"
    
    var displayName: String {
        switch self {
        case .available:
            return "Disponible"
        case .busy:
            return "Occupé"
        case .looking:
            return "En recherche"
        }
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var name: String
    var profileImageURL: String?
    var role: UserRole
    var createdAt: Date
    var updatedAt: Date
    
    // Player specific fields
    var age: Int?
    var city: String?
    var sports: [Sport]?
    var position: String?
    var level: SkillLevel?
    var bio: String?
    var presentationVideoURL: String?
    var status: UserStatus?
    
    // Club specific fields
    var clubName: String?
    var clubLogoURL: String?
    var clubDescription: String?
    var contactEmail: String?
    var contactPhone: String?
    var sportsOffered: [Sport]?
    var location: String?
    
    init(id: UUID = UUID(), email: String, name: String, role: UserRole) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum Sport: String, CaseIterable, Codable {
    case football = "football"
    case basketball = "basketball"
    case tennis = "tennis"
    case rugby = "rugby"
    case volleyball = "volleyball"
    case handball = "handball"
    case badminton = "badminton"
    case tableTennis = "table_tennis"
    case swimming = "swimming"
    case athletics = "athletics"
    case cycling = "cycling"
    case martialArts = "martial_arts"
    case hockey = "hockey"
    case baseball = "baseball"
    case golf = "golf"
    
    var displayName: String {
        switch self {
        case .football:
            return "Football"
        case .basketball:
            return "Basketball"
        case .tennis:
            return "Tennis"
        case .rugby:
            return "Rugby"
        case .volleyball:
            return "Volleyball"
        case .handball:
            return "Handball"
        case .badminton:
            return "Badminton"
        case .tableTennis:
            return "Tennis de table"
        case .swimming:
            return "Natation"
        case .athletics:
            return "Athlétisme"
        case .cycling:
            return "Cyclisme"
        case .martialArts:
            return "Arts martiaux"
        case .hockey:
            return "Hockey"
        case .baseball:
            return "Baseball"
        case .golf:
            return "Golf"
        }
    }
    
    var emoji: String {
        switch self {
        case .football:
            return "⚽"
        case .basketball:
            return "🏀"
        case .tennis:
            return "🎾"
        case .rugby:
            return "🏉"
        case .volleyball:
            return "🏐"
        case .handball:
            return "🤾"
        case .badminton:
            return "🏸"
        case .tableTennis:
            return "🏓"
        case .swimming:
            return "🏊"
        case .athletics:
            return "🏃"
        case .cycling:
            return "🚴"
        case .martialArts:
            return "🥋"
        case .hockey:
            return "🏒"
        case .baseball:
            return "⚾"
        case .golf:
            return "⛳"
        }
    }
}

enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner:
            return "Débutant"
        case .intermediate:
            return "Intermédiaire"
        case .advanced:
            return "Avancé"
        case .expert:
            return "Expert"
        }
    }
}
