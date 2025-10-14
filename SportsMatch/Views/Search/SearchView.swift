//
//  SearchView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header avec recherche
                VStack(spacing: 16) {
                    // Barre de recherche
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textTertiary)
                        
                        TextField("Rechercher joueurs, clubs, offres...", text: $searchText)
                            .font(.callout)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Onglets de recherche
                    HStack(spacing: 0) {
                        SearchTabButton(
                            title: "Joueurs",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        
                        SearchTabButton(
                            title: "Clubs",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        
                        SearchTabButton(
                            title: "Offres",
                            isSelected: selectedTab == 2
                        ) {
                            selectedTab = 2
                        }
                    }
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.background)
                
                // Contenu selon l'onglet sélectionné
                Group {
                    switch selectedTab {
                    case 0:
                        PlayersSearchView(searchText: searchText)
                    case 1:
                        ClubsSearchView(searchText: searchText)
                    case 2:
                        OffersSearchView(searchText: searchText)
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
    }
}

struct SearchTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.primaryBlue : Color.clear)
                )
        }
    }
}

struct PlayersSearchView: View {
    let searchText: String
    @State private var players: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(players) { player in
                    PlayerCard(
                        player: player,
                        onViewProfile: {
                            // Navigation vers profil
                        },
                        onContact: {
                            // Créer conversation
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .overlay(
            Group {
                if isLoading { ProgressView().scaleEffect(1.2) }
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task(id: searchText) {
            await loadPlayers()
        }
    }
    
    private func loadPlayers() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await api.searchUsers(
                filters: UserFilters(role: .player, sport: nil, city: searchText.isEmpty ? nil : searchText, level: nil, position: nil),
                page: 1,
                limit: 20
            )
            players = response.users.filter { $0.role == .player }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct ClubsSearchView: View {
    let searchText: String
    @State private var clubs: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(clubs) { club in
                    ClubCard(
                        club: club,
                        onViewProfile: {
                            // Navigation vers profil
                        },
                        onContact: {
                            // Créer conversation
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .overlay(
            Group {
                if isLoading { ProgressView().scaleEffect(1.2) }
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task(id: searchText) {
            await loadClubs()
        }
    }
    
    private func loadClubs() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await api.searchUsers(
                filters: UserFilters(role: .club, sport: nil, city: searchText.isEmpty ? nil : searchText, level: nil, position: nil),
                page: 1,
                limit: 20
            )
            clubs = response.users.filter { $0.role == .club }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct OffersSearchView: View {
    let searchText: String
    @StateObject private var offerService = OfferService()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(offerService.offers) { offer in
                    OfferCard(
                        offer: offer,
                        clubName: nil,
                        onApply: {
                            // Navigation vers candidature
                        },
                        onViewDetails: {
                            // Navigation vers détails
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            Task {
                await offerService.loadOffers()
            }
        }
    }
}

struct ClubCard: View {
    let club: User
    let onViewProfile: () -> Void
    let onContact: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Logo du club
                AsyncImage(url: URL(string: club.clubLogoURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.surfaceSecondary)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.textTertiary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(club.clubName ?? club.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if let location = club.location {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let sports = club.sportsOffered, !sports.isEmpty {
                        Text(sports.map { $0.displayName }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
            }
            
            if let description = club.clubDescription {
                Text(description)
                    .font(.callout)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
            
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

#Preview {
    SearchView()
}
