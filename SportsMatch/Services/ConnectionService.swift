//
//  ConnectionService.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation
import Combine

@MainActor
class ConnectionService: ObservableObject {
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var lastConnectionTime: Date?
    @Published var connectionError: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var wakeUpTimer: Timer?
    
    init() {
        startPeriodicWakeUp()
    }
    
    deinit {
        wakeUpTimer?.invalidate()
    }
    
    // MARK: - Connection Management
    
    func checkConnection() async {
        isConnecting = true
        connectionError = nil
        
        do {
            // Essayer d'abord de réveiller l'API
            try await wakeUpAPI()
            
            // Puis vérifier la santé de l'API
            let healthResponse = try await apiService.checkHealth()
            
            isConnected = true
            lastConnectionTime = Date()
            connectionError = nil
            
        } catch {
            isConnected = false
            connectionError = error.localizedDescription
        }
        
        isConnecting = false
    }
    
    func wakeUpAPI() async throws {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.wake)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = APIConfig.requestTimeout
        request.httpMethod = "GET"
        
        // Ajouter les headers par défaut
        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.networkError
        }
    }
    
    // MARK: - Automatic Wake Up
    
    private func startPeriodicWakeUp() {
        // Réveiller l'API toutes les 10 minutes pour éviter qu'elle s'endorme
        wakeUpTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.wakeUpAPI()
            }
        }
    }
    
    // MARK: - Retry Logic
    
    func executeWithRetry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...APIConfig.maxRetryAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                if attempt < APIConfig.maxRetryAttempts {
                    // Attendre avant de réessayer
                    try await Task.sleep(nanoseconds: UInt64(APIConfig.retryDelay * 1_000_000_000))
                    
                    // Essayer de réveiller l'API avant la prochaine tentative
                    do {
                        try await wakeUpAPI()
                    } catch {
                        // Ignorer les erreurs de réveil, on va réessayer l'opération principale
                        print("⚠️ Échec du réveil de l'API: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        throw lastError ?? APIError.networkError
    }
}

// MARK: - API Health Check Extension

extension APIService {
    func checkHealth() async throws -> HealthResponse {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.health)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = APIConfig.requestTimeout
        
        // Ajouter les headers par défaut
        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.networkError
        }
        
        return try JSONDecoder().decode(HealthResponse.self, from: data)
    }
}

struct HealthResponse: Codable {
    let status: String
    let timestamp: String
    let version: String
    let uptime: Double?
}
