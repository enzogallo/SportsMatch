//
//  Cards.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct OfferCard: View {
    let offer: Offer
    let clubName: String?
    let onApply: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec sport et statut
            HStack {
                HStack(spacing: 6) {
                    Text(offer.sport.emoji)
                        .font(.title2)
                    Text(offer.sport.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if offer.isUrgent == true {
                    Text("URGENT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.error)
                        .clipShape(Capsule())
                }
            }
            
            // Titre de l'offre
            Text(offer.title)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            // Description
            Text(offer.description)
                .font(.callout)
                .foregroundColor(.textSecondary)
                .lineLimit(3)
            
            // Informations clés
            VStack(alignment: .leading, spacing: 6) {
                if let position = offer.position {
                    InfoRow(icon: "person.fill", text: position)
                }
                
                if let level = offer.level {
                    InfoRow(icon: "star.fill", text: level.displayName)
                }
                
                if let city = offer.city, let location = offer.location {
                    InfoRow(icon: "location.fill", text: "\(city), \(location)")
                }
                
                if let ageRange = offer.ageRange {
                    InfoRow(icon: "calendar", text: ageRange.displayName)
                }
            }
            
            // Footer avec actions
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let clubName = clubName, !clubName.isEmpty {
                        Text("Publié par \(clubName)")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    
                    Text(offer.createdAt ?? Date(), style: .relative)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Voir détails") {
                        onViewDetails()
                    }
                    .buttonStyle(SmallButtonStyle(color: .textSecondary))
                    
                    Button("Postuler") {
                        onApply()
                    }
                    .buttonStyle(SmallButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct PlayerCard: View {
    let player: User
    let onViewProfile: () -> Void
    let onContact: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec photo et infos de base
            HStack(spacing: 12) {
                // Photo de profil
                AsyncImage(url: URL(string: player.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.surfaceSecondary)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.textTertiary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if let age = player.age {
                        Text("\(age) ans")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let city = player.city {
                        Text(city)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
                
                if let status = player.status {
                    StatusBadge(status: status)
                }
            }
            
            // Sports pratiqués
            if let sports = player.sports, !sports.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sports, id: \.self) { sport in
                            SportChip(sport: sport)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Position et niveau
            HStack(spacing: 16) {
                if let position = player.position {
                    InfoRow(icon: "person.fill", text: position)
                }
                
                if let level = player.level {
                    InfoRow(icon: "star.fill", text: level.displayName)
                }
            }
            
            // Bio
            if let bio = player.bio, !bio.isEmpty {
                Text(bio)
                    .font(.callout)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button("Voir profil") {
                    onViewProfile()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Contacter") {
                    onContact()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.textTertiary)
                .frame(width: 12)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

struct StatusBadge: View {
    let status: UserStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .available:
            return .success
        case .busy:
            return .warning
        case .looking:
            return .info
        }
    }
}

struct SportChip: View {
    let sport: Sport
    
    var body: some View {
        HStack(spacing: 4) {
            Text(sport.emoji)
                .font(.caption)
            Text(sport.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.primaryBlue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primaryBlue.opacity(0.1))
        .clipShape(Capsule())
    }
}
