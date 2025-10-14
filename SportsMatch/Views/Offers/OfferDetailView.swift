//
//  OfferDetailView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct OfferDetailView: View {
    let offer: Offer
    @Environment(\.dismiss) private var dismiss
    @State private var showingApplication = false
    @State private var isFavorite = false
    
    // Chargement des détails à partir de l'API pour éviter toute donnée obsolète/partielle
    @State private var fullOffer: Offer?
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
                // Header avec image et actions
                VStack(alignment: .leading, spacing: 16) {
                    // Image de l'offre
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Text(offer.sport.emoji)
                                    .font(.system(size: 60))
                                Text(offer.sport.displayName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textSecondary)
                            }
                        )
                    
                    // Titre et statut
                    HStack {
                        let current = fullOffer ?? offer
                        VStack(alignment: .leading, spacing: 8) {
                            Text(current.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: 12) {
                                OfferStatusBadge(status: current.status)
                                
                                if current.isUrgent {
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
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isFavorite.toggle()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .error : .textTertiary)
                        }
                    }
                }
                
                // Informations du club (sans valeurs en dur)
                let current = fullOffer ?? offer
                ClubInfoCard(
                    clubName: nil,
                    location: "\(current.city), \(current.location)",
                    contactEmail: nil
                )
                
                // Détails de l'offre
                OfferDetailsCard(offer: fullOffer ?? offer)
                
                // Description
                DescriptionCard(description: (fullOffer ?? offer).description)
                
                // Actions
                VStack(spacing: 12) {
                    if authService.currentUser?.role == .player {
                        Button("Postuler à cette offre") {
                            showingApplication = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    Button("Contacter le club") {
                        Task { await contactClub() }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("Détails de l'offre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Fermer") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingApplication) {
            ApplicationView(offer: fullOffer ?? offer)
                .environmentObject(AuthService())
        }
        .overlay(
            Group { if isLoading { ProgressView().scaleEffect(1.2) } }
        )
        .task {
            await loadOffer()
        }
    }
}

private extension OfferDetailView {
    func loadOffer() async {
        isLoading = true
        errorMessage = nil
        do {
            let detail = try await api.getOffer(id: offer.id)
            fullOffer = detail.offer
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

private extension OfferDetailView {
    var authService: AuthService { AuthService() }
    
    func contactClub() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        do {
            // participantId = clubId de l'offre
            let conv = try await api.createConversation(participantId: offer.clubId, token: token)
            // Navigation vers la conversation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ClubInfoCard: View {
    let clubName: String?
    let location: String?
    let contactEmail: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("À propos du club")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.textTertiary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    if let clubName, !clubName.isEmpty {
                        Text(clubName)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    if let location, !location.isEmpty {
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let contactEmail, !contactEmail.isEmpty {
                        Text(contactEmail)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct OfferDetailsCard: View {
    let offer: Offer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Détails de l'offre")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                if let position = offer.position {
                    DetailRow(icon: "person.fill", title: "Poste", value: position)
                }
                
                if let level = offer.level {
                    DetailRow(icon: "star.fill", title: "Niveau", value: level.displayName)
                }
                
                DetailRow(icon: "location.fill", title: "Lieu", value: "\(offer.city), \(offer.location)")
                
                if let ageRange = offer.ageRange {
                    DetailRow(icon: "calendar", title: "Âge", value: ageRange.displayName)
                }
                
                DetailRow(icon: "clock", title: "Type", value: offer.type.displayName)
                
                DetailRow(icon: "person.2.fill", title: "Candidatures", value: "\(offer.currentApplications) candidatures")
            }
        }
        .padding(20)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundColor(.textTertiary)
                .frame(width: 20)
            
            Text(title)
                .font(.callout)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

struct DescriptionCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(description)
                .font(.callout)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct OfferStatusBadge: View {
    let status: OfferStatus
    
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
        case .active:
            return .success
        case .paused:
            return .warning
        case .closed:
            return .textTertiary
        case .filled:
            return .info
        }
    }
}

#Preview {
    NavigationView {
        OfferDetailView(offer: Offer(
            clubId: UUID(),
            title: "Recherche gardien de but",
            description: "Notre équipe de football amateur cherche un gardien de but expérimenté pour la saison prochaine.",
            sport: .football,
            location: "Stade Municipal",
            city: "Paris"
        ))
    }
}
