//
//  FeedView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var offerService = OfferService()
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header avec recherche et filtres
                VStack(spacing: 16) {
                    // Barre de recherche
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textTertiary)
                        
                        TextField("Rechercher une offre...", text: $searchText)
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
                    
                    // Filtres rapides
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "Tous", isSelected: true)
                            FilterChip(title: "Football", isSelected: false)
                            FilterChip(title: "Basketball", isSelected: false)
                            FilterChip(title: "Tennis", isSelected: false)
                            FilterChip(title: "Rugby", isSelected: false)
                            
                            Button(action: {
                                showingFilters = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.caption)
                                    Text("Filtres")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.primaryBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.primaryBlue.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.background)
                
                // Liste des offres
                if offerService.isLoading {
                    Spacer()
                    ProgressView("Chargement des offres...")
                        .foregroundColor(.textSecondary)
                    Spacer()
                } else if offerService.offers.isEmpty {
                    EmptyStateView(
                        icon: "sportscourt",
                        title: "Aucune offre disponible",
                        description: "Il n'y a pas d'offres pour le moment. Revenez plus tard !"
                    )
                } else {
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
                }
            }
            .navigationTitle("SportsMatch")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView()
        }
        .onAppear {
            Task {
                await offerService.loadOffers()
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.primaryBlue : Color.surfaceSecondary)
            )
    }
}

struct EmptyStateView: View {
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
    FeedView()
}
