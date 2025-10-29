//
//  FavoritesView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var authService: AuthService
    @State private var favoritePlayers: [User] = []
    @State private var favoriteClubs: [User] = []
    @State private var favoriteOffers: [Offer] = []
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Onglets
                HStack(spacing: 0) {
                    FavoriteTabButton(
                        title: "Offres",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    FavoriteTabButton(
                        title: "Joueurs",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    FavoriteTabButton(
                        title: "Clubs",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                }
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Contenu selon l'onglet
                Group {
                    switch selectedTab {
                    case 0:
                        OffersFavoritesView(
                            offers: favoriteOffers,
                            isLoading: isLoading,
                            errorMessage: errorMessage
                        )
                    case 1:
                        PlayersFavoritesView(
                            players: favoritePlayers,
                            isLoading: isLoading,
                            errorMessage: errorMessage
                        )
                    case 2:
                        ClubsFavoritesView(
                            clubs: favoriteClubs,
                            isLoading: isLoading,
                            errorMessage: errorMessage
                        )
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Favoris")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
        .overlay(
            Group {
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task {
            await loadFavorites()
        }
    }
    
    private func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = authService.getStoredToken() else { throw APIError.invalidCredentials }
            
            async let offersTask = api.getFavoriteOffers(token: token)
            async let playersTask = api.getFavoriteUsers(type: "player", token: token)
            async let clubsTask = api.getFavoriteUsers(type: "club", token: token)
            
            let (offersResult, playersResult, clubsResult) = try await (offersTask, playersTask, clubsTask)
            
            favoriteOffers = offersResult.offers
            favoritePlayers = playersResult.users
            favoriteClubs = clubsResult.users
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct OffersFavoritesView: View {
    let offers: [Offer]
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        if isLoading {
            Spacer()
            ProgressView("Chargement des favoris...")
                .foregroundColor(.textSecondary)
            Spacer()
        } else if offers.isEmpty {
            EmptyFavoritesView(
                icon: "heart",
                title: "Aucune offre favorite",
                description: "Les offres que vous ajoutez en favori apparaîtront ici."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(offers) { offer in
                        NavigationLink(destination: OfferDetailView(offer: offer)) {
                            OfferCard(
                                offer: offer,
                                clubName: nil,
                                onApply: {},
                                onViewDetails: {}
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct FavoriteTabButton: View {
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

struct PlayersFavoritesView: View {
    let players: [User]
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        if isLoading {
            Spacer()
            ProgressView("Chargement des favoris...")
                .foregroundColor(.textSecondary)
            Spacer()
        } else if players.isEmpty {
            EmptyFavoritesView(
                icon: "person.2",
                title: "Aucun joueur favori",
                description: "Les joueurs que vous ajoutez en favori apparaîtront ici."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(players) { player in
                        FavoritePlayerCard(player: player)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ClubsFavoritesView: View {
    let clubs: [User]
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        if isLoading {
            Spacer()
            ProgressView("Chargement des favoris...")
                .foregroundColor(.textSecondary)
            Spacer()
        } else if clubs.isEmpty {
            EmptyFavoritesView(
                icon: "building.2",
                title: "Aucun club favori",
                description: "Les clubs que vous ajoutez en favori apparaîtront ici."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(clubs) { club in
                        FavoriteClubCard(club: club)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct FavoritePlayerCard: View {
    let player: User
    @State private var isFavorite = true
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.surfaceSecondary)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.textTertiary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                if let city = player.city {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                if let sports = player.sports, !sports.isEmpty {
                    Text(sports.map { $0.displayName }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            Button(action: {
                isFavorite.toggle()
                // Toggle favorite status
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(isFavorite ? .error : .textTertiary)
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FavoriteClubCard: View {
    let club: User
    @State private var isFavorite = true
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.surfaceSecondary)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.textTertiary)
                )
            
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
            
            Button(action: {
                isFavorite.toggle()
                // Toggle favorite status
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(isFavorite ? .error : .textTertiary)
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EmptyFavoritesView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(description)
                .font(.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AuthService())
}
