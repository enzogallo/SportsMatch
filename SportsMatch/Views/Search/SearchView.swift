//
//  SearchView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var authService: AuthService
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showingFilters = false
    @State private var selectedPlayer: User?
    @State private var selectedClub: User?
    @State private var selectedOffer: Offer?
    @State private var showingPlayerProfile = false
    @State private var showingClubProfile = false
    @State private var showingOfferDetail = false
    @State private var showingApplication = false
    @State private var showingNewConversation = false
    @State private var showingCreateOffer = false
    
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
                        PlayersSearchView(
                            searchText: searchText,
                            onViewProfile: { player in
                                selectedPlayer = player
                                showingPlayerProfile = true
                            },
                            onContact: { player in
                                selectedPlayer = player
                                showingNewConversation = true
                            }
                        )
                    case 1:
                        ClubsSearchView(
                            searchText: searchText,
                            onViewProfile: { club in
                                selectedClub = club
                                showingClubProfile = true
                            },
                            onContact: { club in
                                selectedClub = club
                                showingNewConversation = true
                            },
                            onCreateOffer: authService.currentUser?.role == .club ? {
                                showingCreateOffer = true
                            } : nil
                        )
                    case 2:
                        OffersSearchView(
                            searchText: searchText,
                            onApply: { offer in
                                selectedOffer = offer
                                showingApplication = true
                            },
                            onViewDetails: { offer in
                                selectedOffer = offer
                                showingOfferDetail = true
                            }
                        )
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
        .sheet(isPresented: $showingPlayerProfile) {
            if let player = selectedPlayer {
                PlayerProfileView(playerId: player.id)
            }
        }
        .sheet(isPresented: $showingClubProfile) {
            if let club = selectedClub {
                PlayerProfileView(playerId: club.id) // Reuse PlayerProfileView for clubs
            }
        }
        .sheet(isPresented: $showingOfferDetail) {
            if let offer = selectedOffer {
                OfferDetailView(offer: offer)
            }
        }
        .sheet(isPresented: $showingApplication) {
            if let offer = selectedOffer {
                ApplicationView(offer: offer)
                    .environmentObject(AuthService())
            }
        }
        .sheet(isPresented: $showingNewConversation) {
            NewConversationView(
                participant: selectedPlayer ?? selectedClub,
                onDismiss: {
                    selectedPlayer = nil
                    selectedClub = nil
                }
            )
        }
        .sheet(isPresented: $showingCreateOffer) {
            CreateOfferView()
                .environmentObject(authService)
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
    let onViewProfile: (User) -> Void
    let onContact: (User) -> Void
    @State private var players: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        Group {
            if players.isEmpty && !isLoading {
                EmptySearchView(
                    icon: "person.2",
                    title: searchText.isEmpty ? "Aucun joueur trouvé" : "Aucun résultat",
                    description: searchText.isEmpty ? "Les joueurs apparaîtront ici." : "Essayez avec d'autres mots-clés."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(players) { player in
                            PlayerCard(
                                player: player,
                                onViewProfile: {
                                    onViewProfile(player)
                                },
                                onContact: {
                                    onContact(player)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            print("🔵 PlayersSearchView: onAppear - players.count: \(players.count), isLoading: \(isLoading)")
        }
        .onChange(of: players) { newPlayers in
            print("🔵 PlayersSearchView: players changed - count: \(newPlayers.count)")
        }
        .onChange(of: isLoading) { newIsLoading in
            print("🔵 PlayersSearchView: isLoading changed - \(newIsLoading)")
        }
        .overlay(
            Group {
                if isLoading { ProgressView().scaleEffect(1.2) }
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .onAppear {
            Task {
                await loadPlayers()
            }
        }
        .task(id: searchText) {
            // Délai de 500ms pour éviter trop d'appels API
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadPlayers()
        }
    }
    
    private func loadPlayers() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await api.searchUsers(
                filters: UserFilters(
                    role: .player, 
                    sport: nil, 
                    city: searchText.isEmpty ? nil : searchText, 
                    level: nil, 
                    position: nil
                ),
                page: 1,
                limit: 20
            )
            players = response.users
            isLoading = false
            
            // Debug logging
            print("🔵 PlayersSearchView: Loaded \(players.count) players")
            for player in players {
                print("🔵 Player: \(player.name) (ID: \(player.id))")
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("🔴 PlayersSearchView: Error loading players: \(error.localizedDescription)")
        }
    }
}

struct ClubsSearchView: View {
    let searchText: String
    let onViewProfile: (User) -> Void
    let onContact: (User) -> Void
    let onCreateOffer: (() -> Void)?
    @State private var clubs: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        Group {
            if clubs.isEmpty && !isLoading {
                EmptySearchView(
                    icon: "building.2",
                    title: searchText.isEmpty ? "Aucun club trouvé" : "Aucun résultat",
                    description: searchText.isEmpty ? "Les clubs apparaîtront ici." : "Essayez avec d'autres mots-clés.",
                    actionTitle: onCreateOffer != nil ? "Créer une offre" : nil,
                    action: onCreateOffer
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(clubs) { club in
                            ClubCard(
                                club: club,
                                onViewProfile: {
                                    onViewProfile(club)
                                },
                                onContact: {
                                    onContact(club)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .overlay(
            Group {
                if isLoading { ProgressView().scaleEffect(1.2) }
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task(id: searchText) {
            // Délai de 500ms pour éviter trop d'appels API
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadClubs()
        }
    }
    
    private func loadClubs() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await api.searchUsers(
                filters: UserFilters(
                    role: .club, 
                    sport: nil, 
                    city: searchText.isEmpty ? nil : searchText, 
                    level: nil, 
                    position: nil
                ),
                page: 1,
                limit: 20
            )
            clubs = response.users
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct OffersSearchView: View {
    let searchText: String
    let onApply: (Offer) -> Void
    let onViewDetails: (Offer) -> Void
    @StateObject private var offerService = OfferService()
    @State private var filteredOffers: [Offer] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredOffers) { offer in
                    OfferCard(
                        offer: offer,
                        clubName: nil,
                        onApply: {
                            onApply(offer)
                        },
                        onViewDetails: {
                            onViewDetails(offer)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            Task {
                await loadOffers()
            }
        }
        .onChange(of: searchText) { _ in
            Task {
                await filterOffers()
            }
        }
    }
    
    private func loadOffers() async {
        await offerService.loadOffers()
        await filterOffers()
    }
    
    private func filterOffers() async {
        if searchText.isEmpty {
            filteredOffers = offerService.offers
        } else {
            filteredOffers = offerService.offers.filter { offer in
                offer.title.localizedCaseInsensitiveContains(searchText) ||
                offer.description.localizedCaseInsensitiveContains(searchText) ||
                (offer.city?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                offer.sport.displayName.localizedCaseInsensitiveContains(searchText)
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

struct EmptySearchView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
}
