//
//  AppConfig.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

struct AppConfig {
    static let appName = "SportsMatch"
    static let appVersion = "1.0.0"
    static let appSlogan = "Trouve ton équipe. Trouve ton match."
    
    // URLs de l'API (à configurer selon votre backend)
    static let baseURL = "https://api.sportsmatch.com"
    static let apiVersion = "v1"
    
    // Limites de l'application
    static let maxApplicationsPerWeek = 3
    static let maxOffersPerClub = 5
    static let maxMessageLength = 1000
    static let maxBioLength = 500
    
    // Configuration des notifications
    static let notificationDelay = 2.0 // secondes
    static let maxRetryAttempts = 3
    
    // Configuration des images
    static let maxImageSize = 5 * 1024 * 1024 // 5MB
    static let supportedImageFormats = ["jpg", "jpeg", "png", "heic"]
    
    // Configuration de la géolocalisation
    static let defaultSearchRadius = 50.0 // km
    static let maxSearchRadius = 200.0 // km
    
    // Configuration des abonnements
    static let freeTrialDays = 7
    static let playerPremiumPrice = 2.99
    static let clubPremiumPrice = 9.99
}
