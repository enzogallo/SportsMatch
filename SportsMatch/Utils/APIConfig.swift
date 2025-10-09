//
//  APIConfig.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

struct APIConfig {
    // Configuration dynamique de l'API
    static let baseURL: String = {
        // Vérifier d'abord les variables d'environnement (pour les tests)
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        
        // Configuration par défaut selon l'environnement
        #if DEBUG
        // En développement, utiliser localhost ou Render
        return "https://sportsmatch.onrender.com"
        #else
        // En production, utiliser Render
        return "https://sportsmatch.onrender.com"
        #endif
    }()
    
    // Timeout pour les requêtes
    static let requestTimeout: TimeInterval = 30.0
    
    // Nombre de tentatives de reconnexion
    static let maxRetryAttempts = 3
    
    // Délai entre les tentatives (en secondes)
    static let retryDelay: TimeInterval = 2.0
    
    // Endpoints
    struct Endpoints {
        static let health = "/api/health"
        static let wake = "/api/wake"
        static let auth = "/api/auth"
        static let users = "/api/users"
        static let offers = "/api/offers"
        static let applications = "/api/applications"
        static let messages = "/api/messages"
    }
    
    // Headers par défaut
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "SportsMatch-iOS/1.0.0"
    ]
}
