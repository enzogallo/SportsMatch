//
//  OfferService.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation
import Combine

@MainActor
class OfferService: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        // Plus de données d'exemple, on charge depuis l'API
    }
    
    func loadOffers(filters: OfferFilters? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getOffers(filters: filters)
            offers = response.offers
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func createOffer(_ offer: Offer, token: String) async {
        isLoading = true
        
        do {
            let createRequest = CreateOfferRequest(
                title: offer.title,
                description: offer.description,
                sport: offer.sport.rawValue,
                position: offer.position,
                level: offer.level?.rawValue,
                type: offer.type.rawValue,
                location: offer.location,
                city: offer.city,
                min_age: offer.ageRange?.min,
                max_age: offer.ageRange?.max,
                is_urgent: offer.isUrgent,
                max_applications: offer.maxApplications
            )
            
            let response = try await apiService.createOffer(createRequest, token: token)
            offers.insert(response.offer, at: 0)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func updateOffer(_ offer: Offer) async {
        isLoading = true
        
        // Simulation d'une mise à jour (remplacer par une vraie API)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconde
        
        if let index = offers.firstIndex(where: { $0.id == offer.id }) {
            offers[index] = offer
        }
        isLoading = false
    }
    
    func deleteOffer(_ offer: Offer) async {
        isLoading = true
        
        // Simulation d'une suppression (remplacer par une vraie API)
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconde
        
        offers.removeAll { $0.id == offer.id }
        isLoading = false
    }
    
}

struct OfferFilters {
    let sport: Sport?
    let city: String?
    let level: SkillLevel?
    let position: String?
    let maxDistance: Double?
}
