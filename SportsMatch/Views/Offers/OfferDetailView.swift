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
    @State private var isLoadingFavorite = false
    
    // Chargement des détails à partir de l'API pour éviter toute donnée obsolète/partielle
    @State private var fullOffer: Offer?
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    @EnvironmentObject var authService: AuthService
    @StateObject private var performanceService = PerformanceService()
    @State private var performanceSummary: PerformanceSummary?
    
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
                                if let status = current.status {
                                    OfferStatusBadge(status: status)
                                }
                                
                                if current.isUrgent == true {
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
                            Task {
                                await toggleFavorite()
                            }
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .error : .textTertiary)
                                .opacity(isLoadingFavorite ? 0.5 : 1.0)
                        }
                        .disabled(isLoadingFavorite)
                    }
                }
                
                // Informations du club (sans valeurs en dur)
                let current = fullOffer ?? offer
                ClubInfoCard(
                    clubName: nil,
                    location: "\(current.city), \(current.location)",
                    contactEmail: nil
                )
                
                // CV express du joueur (si connecté en tant que joueur)
                if authService.currentUser?.role == .player, let performanceSummary {
                    PerformanceStatGrid(summary: performanceSummary, sport: (fullOffer ?? offer).sport)
                }
                
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
                .environmentObject(authService)
        }
        .overlay(
            Group { if isLoading { ProgressView().scaleEffect(1.2) } }
        )
        .task {
            await loadOffer()
            await checkFavoriteStatus()
            let token = authService.getStoredToken()
            performanceSummary = await performanceService.fetchSummary(forUserId: authService.currentUser?.id, token: token)
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
    func contactClub() async {
        guard let token = authService.getStoredToken() else { return }
        do {
            // participantId = clubId de l'offre
            let conv = try await api.createConversation(participantId: offer.clubId, token: token)
            // Navigation vers la conversation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkFavoriteStatus() async {
        guard let token = authService.getStoredToken() else {
            print("⚠️ Pas de token pour vérifier le favori")
            return
        }
        do {
            let currentOffer = fullOffer ?? offer
            print("🔍 Vérification favori - Offer ID: \(currentOffer.id)")
            isFavorite = try await api.checkFavorite(itemType: "offer", itemId: currentOffer.id, token: token)
            print("✅ Statut favori: \(isFavorite)")
        } catch {
            // Si erreur, on laisse isFavorite à false (c'est OK si la table n'existe pas encore)
            print("❌ Erreur vérification favori: \(error.localizedDescription)")
            if let apiError = error as? APIError {
                print("   Type d'erreur API: \(apiError)")
            }
        }
    }
    
    func toggleFavorite() async {
        guard let token = authService.getStoredToken() else {
            errorMessage = "Vous devez être connecté pour ajouter un favori"
            return
        }
        isLoadingFavorite = true
        defer { isLoadingFavorite = false }
        
        let currentOffer = fullOffer ?? offer
        
        do {
            if isFavorite {
                print("🗑️ Suppression favori - Offer ID: \(currentOffer.id)")
                try await api.removeFavorite(itemType: "offer", itemId: currentOffer.id, token: token)
                isFavorite = false
                print("✅ Favori supprimé avec succès")
            } else {
                print("➕ Ajout favori - Offer ID: \(currentOffer.id)")
                try await api.addFavorite(itemType: "offer", itemId: currentOffer.id, token: token)
                isFavorite = true
                print("✅ Favori ajouté avec succès")
            }
            errorMessage = nil // Effacer les erreurs précédentes en cas de succès
        } catch {
            let errorMsg = error.localizedDescription
            print("❌ Erreur toggleFavorite: \(errorMsg)")
            errorMessage = "Erreur: \(errorMsg)"
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
                
                if let city = offer.city, let location = offer.location {
                    DetailRow(icon: "location.fill", title: "Lieu", value: "\(city), \(location)")
                }
                
                if let ageRange = offer.ageRange {
                    DetailRow(icon: "calendar", title: "Âge", value: ageRange.displayName)
                }
                
                if let type = offer.type {
                    DetailRow(icon: "clock", title: "Type", value: type.displayName)
                }
                
                DetailRow(icon: "person.2.fill", title: "Candidatures", value: "\(offer.currentApplications ?? 0) candidatures")
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
