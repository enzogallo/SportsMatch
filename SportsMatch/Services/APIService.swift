//
//  APIService.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = APIConfig.baseURL
    private let session: URLSession
    
    init() {
        // Configuration de la session avec timeout personnalisé
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.requestTimeout
        config.timeoutIntervalForResource = APIConfig.requestTimeout * 2
        self.session = URLSession(configuration: config)
    }
    
    
    // MARK: - Auth Endpoints
    
    func register(email: String, password: String, name: String, role: UserRole) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RegisterRequest(email: email, password: password, name: name, role: role.rawValue)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidCredentials
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func getCurrentUser(token: String) async throws -> User {
        let url = URL(string: "\(baseURL)/api/auth/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let authResponse = try JSONDecoder().decode(MeResponse.self, from: data)
        return authResponse.user
    }
    
    // MARK: - Offers Endpoints
    
    func getOffers(filters: OfferFilters? = nil, page: Int = 1, limit: Int = 20) async throws -> OffersResponse {
        var components = URLComponents(string: "\(baseURL)/api/offers")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let filters = filters {
            if let sport = filters.sport {
                queryItems.append(URLQueryItem(name: "sport", value: sport.rawValue))
            }
            if let city = filters.city {
                queryItems.append(URLQueryItem(name: "city", value: city))
            }
            if let level = filters.level {
                queryItems.append(URLQueryItem(name: "level", value: level.rawValue))
            }
            if let position = filters.position {
                queryItems.append(URLQueryItem(name: "position", value: position))
            }
        }
        
        components.queryItems = queryItems
        
        let (data, response) = try await session.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(OffersResponse.self, from: data)
    }
    
    func getOffer(id: UUID, token: String? = nil) async throws -> OfferDetailResponse {
        let url = URL(string: "\(baseURL)/api/offers/\(id)")!
        var request = URLRequest(url: url)
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(OfferDetailResponse.self, from: data)
    }
    
    func createOffer(_ offer: CreateOfferRequest, token: String) async throws -> OfferResponse {
        let url = URL(string: "\(baseURL)/api/offers")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode(offer)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(OfferResponse.self, from: data)
    }
    
    // MARK: - Applications Endpoints
    
    func getMyApplications(token: String) async throws -> ApplicationsResponse {
        let url = URL(string: "\(baseURL)/api/applications/my")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(ApplicationsResponse.self, from: data)
    }
    
    func applyToOffer(offerId: UUID, message: String?, token: String) async throws -> ApplicationResponse {
        let url = URL(string: "\(baseURL)/api/applications")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ApplyRequest(offer_id: offerId, message: message)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(ApplicationResponse.self, from: data)
    }
    
    // MARK: - Users Endpoints
    
    func searchUsers(filters: UserFilters? = nil, page: Int = 1, limit: Int = 20) async throws -> UsersResponse {
        var components = URLComponents(string: "\(baseURL)/api/users")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let filters = filters {
            if let role = filters.role {
                queryItems.append(URLQueryItem(name: "role", value: role.rawValue))
            }
            if let sport = filters.sport {
                queryItems.append(URLQueryItem(name: "sport", value: sport.rawValue))
            }
            if let city = filters.city {
                queryItems.append(URLQueryItem(name: "city", value: city))
            }
            if let level = filters.level {
                queryItems.append(URLQueryItem(name: "level", value: level.rawValue))
            }
            if let position = filters.position {
                queryItems.append(URLQueryItem(name: "position", value: position))
            }
        }
        
        components.queryItems = queryItems
        
        let (data, response) = try await session.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(UsersResponse.self, from: data)
    }
    
    func updateUser(id: UUID, user: UpdateUserRequest, token: String) async throws -> UserResponse {
        let url = URL(string: "\(baseURL)/api/users/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode(user)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
}

// MARK: - Request/Response Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let role: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let message: String
    let user: User
    let token: String
}

struct MeResponse: Codable {
    let user: User
}

struct OffersResponse: Codable {
    let offers: [Offer]
    let pagination: Pagination
}

struct OfferDetailResponse: Codable {
    let offer: Offer
}

struct OfferResponse: Codable {
    let message: String
    let offer: Offer
}

struct ApplicationsResponse: Codable {
    let applications: [Application]
}

struct ApplicationResponse: Codable {
    let message: String
    let application: Application
}

struct UsersResponse: Codable {
    let users: [User]
    let pagination: Pagination
}

struct UserResponse: Codable {
    let message: String
    let user: User
}

struct ApplyRequest: Codable {
    let offer_id: UUID
    let message: String?
}

struct CreateOfferRequest: Codable {
    let title: String
    let description: String
    let sport: String
    let position: String?
    let level: String?
    let type: String
    let location: String
    let city: String
    let min_age: Int?
    let max_age: Int?
    let is_urgent: Bool
    let max_applications: Int?
}

struct UpdateUserRequest: Codable {
    let name: String?
    let age: Int?
    let city: String?
    let sports: [String]?
    let position: String?
    let level: String?
    let bio: String?
    let profile_image_url: String?
    let status: String?
    let club_name: String?
    let club_logo_url: String?
    let club_description: String?
    let contact_email: String?
    let contact_phone: String?
    let sports_offered: [String]?
    let location: String?
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}

struct UserFilters {
    let role: UserRole?
    let sport: Sport?
    let city: String?
    let level: SkillLevel?
    let position: String?
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidResponse
    case invalidCredentials
    case networkError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .invalidCredentials:
            return "Email ou mot de passe incorrect"
        case .networkError:
            return "Erreur de connexion réseau"
        case .decodingError:
            return "Erreur de décodage des données"
        }
    }
}
