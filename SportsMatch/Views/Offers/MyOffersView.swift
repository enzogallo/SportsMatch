//
//  MyOffersView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import SwiftUI

struct MyOffersView: View {
    @EnvironmentObject var authService: AuthService
    @State private var offers: [Offer] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    Spacer()
                    ProgressView("Chargement de vos offres...")
                        .foregroundColor(.textSecondary)
                    Spacer()
                } else if offers.isEmpty {
                    EmptyOffersView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(offers) { offer in
                                MyOfferCard(offer: offer)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Mes offres")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
        .overlay(
            Group {
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task {
            await loadMyOffers()
        }
    }
    
    private func loadMyOffers() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = authService.getStoredToken() else { throw APIError.invalidCredentials }
            let response = try await api.getMyOffers(token: token)
            offers = response.offers
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct MyOfferCard: View {
    let offer: Offer
    @State private var showingApplications = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(offer.sport.displayName) • \(offer.city ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let status = offer.status {
                    OfferStatusBadge(status: status)
                }
            }
            
            Text(offer.description)
                .font(.callout)
                .foregroundColor(.textSecondary)
                .lineLimit(3)
            
            HStack {
                Text("\(offer.currentApplications ?? 0) candidatures")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                Text("Publié le \(offer.createdAt ?? Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            
            HStack(spacing: 12) {
                Button("Voir candidatures") {
                    showingApplications = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Modifier") {
                    // Navigation vers édition d'offre
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingApplications) {
            OfferApplicationsView(offer: offer)
        }
    }
}

struct OfferApplicationsView: View {
    let offer: Offer
    @Environment(\.dismiss) private var dismiss
    @State private var applications: [Application] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    Spacer()
                    ProgressView("Chargement des candidatures...")
                        .foregroundColor(.textSecondary)
                    Spacer()
                } else if applications.isEmpty {
                    EmptyApplicationsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(applications) { application in
                                ApplicationDetailCard(application: application)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Candidatures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .overlay(
            Group {
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task {
            await loadApplications()
        }
    }
    
    private func loadApplications() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = UserDefaults.standard.string(forKey: "auth_token") else { throw APIError.invalidCredentials }
            let response = try await api.getOfferApplications(offerId: offer.id, token: token)
            applications = response.applications
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct ApplicationDetailCard: View {
    let application: Application
    @State private var showingPlayerProfile = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.textTertiary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.playerName)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Candidaté le \(application.createdAt ?? Date(), style: .date)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let status = application.status {
                    ApplicationStatusBadge(status: status)
                }
            }
            
            if let message = application.message, !message.isEmpty {
                Text(message)
                    .font(.callout)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            
            HStack(spacing: 12) {
                Button("Voir profil") {
                    showingPlayerProfile = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                if application.status == .pending {
                    Button("Accepter") {
                        // Accepter candidature
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Refuser") {
                        // Refuser candidature
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingPlayerProfile) {
            PlayerProfileView(playerId: application.playerId)
        }
    }
}

struct EmptyOffersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("Aucune offre")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Vos offres publiées apparaîtront ici.")
                .font(.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyOffersView()
        .environmentObject(AuthService())
}
