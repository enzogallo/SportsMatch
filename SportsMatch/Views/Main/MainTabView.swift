//
//  MainTabView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    @State private var showingCreateOffer = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed des offres
            FeedView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Accueil")
                }
                .tag(0)
            
            // Recherche
            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Recherche")
                }
                .tag(1)
            
            // Messages
            MessagesView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "message.fill" : "message")
                    Text("Messages")
                }
                .tag(2)
            
            // Profil
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profil")
                }
                .tag(3)
        }
        .accentColor(.primaryBlue)
        .sheet(isPresented: $showingCreateOffer) {
            CreateOfferView()
        }
        .onAppear {
            // Configuration de l'apparence des onglets
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.surface)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
}
