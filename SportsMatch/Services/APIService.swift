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
    
    // Décodeur JSON commun avec stratégies adaptées aux réponses du backend
    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            // Essaye ISO8601 avec fractions, puis sans
            let isoWithFraction = ISO8601DateFormatter()
            isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = isoWithFraction.date(from: dateString) { return d }
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            if let d = iso.date(from: dateString) { return d }
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Invalid ISO8601 date: \(dateString)")
            )
        }
        return decoder
    }
    
    
    // MARK: - Auth Endpoints
    
    func register(email: String, password: String, name: String, role: UserRole) async throws -> AuthResponse {
        let endpoint = "/api/auth/register"
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RegisterRequest(email: email, password: password, name: name, role: role.rawValue)
        request.httpBody = try JSONEncoder().encode(body)
        
        // Log request
        LoggingService.shared.logAPIRequest(
            endpoint: endpoint,
            method: "POST",
            headers: request.allHTTPHeaderFields,
            body: request.httpBody
        )
        
        let startTime = Date()
        let (data, response) = try await session.data(for: request)
        let duration = Date().timeIntervalSince(startTime)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            LoggingService.shared.logAPIError(
                endpoint: endpoint,
                method: "POST",
                statusCode: nil,
                error: APIError.networkError,
                requestData: request.httpBody,
                responseData: data
            )
            throw APIError.networkError
        }
        
        // Log response
        LoggingService.shared.logAPIResponse(
            endpoint: endpoint,
            method: "POST",
            statusCode: httpResponse.statusCode,
            responseData: data,
            duration: duration
        )
        
        if httpResponse.statusCode == 201 {
            return try makeDecoder().decode(AuthResponse.self, from: data)
        } else {
            // Essayer de décoder le message d'erreur du serveur
            if let errorResponse = try? makeDecoder().decode(ErrorResponse.self, from: data) {
                let error = APIError.serverError(errorResponse.error)
                LoggingService.shared.logAPIError(
                    endpoint: endpoint,
                    method: "POST",
                    statusCode: httpResponse.statusCode,
                    error: error,
                    requestData: request.httpBody,
                    responseData: data,
                    additionalInfo: [
                        "error_details": errorResponse.error,
                        "user_email": email,
                        "user_role": role.rawValue
                    ]
                )
                throw error
            } else {
                let error = APIError.invalidResponse
                LoggingService.shared.logAPIError(
                    endpoint: endpoint,
                    method: "POST",
                    statusCode: httpResponse.statusCode,
                    error: error,
                    requestData: request.httpBody,
                    responseData: data,
                    additionalInfo: [
                        "user_email": email,
                        "user_role": role.rawValue
                    ]
                )
                throw error
            }
        }
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/api/auth/login"
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        // Log request
        LoggingService.shared.logAPIRequest(
            endpoint: endpoint,
            method: "POST",
            headers: request.allHTTPHeaderFields,
            body: request.httpBody
        )
        
        let startTime = Date()
        let (data, response) = try await session.data(for: request)
        let duration = Date().timeIntervalSince(startTime)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            LoggingService.shared.logAPIError(
                endpoint: endpoint,
                method: "POST",
                statusCode: nil,
                error: APIError.networkError,
                requestData: request.httpBody,
                responseData: data
            )
            throw APIError.networkError
        }
        
        // Log response
        LoggingService.shared.logAPIResponse(
            endpoint: endpoint,
            method: "POST",
            statusCode: httpResponse.statusCode,
            responseData: data,
            duration: duration
        )
        
        guard httpResponse.statusCode == 200 else {
            let error = APIError.invalidCredentials
            LoggingService.shared.logAPIError(
                endpoint: endpoint,
                method: "POST",
                statusCode: httpResponse.statusCode,
                error: error,
                requestData: request.httpBody,
                responseData: data,
                additionalInfo: [
                    "user_email": email
                ]
            )
            throw error
        }
        
        return try makeDecoder().decode(AuthResponse.self, from: data)
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
        
        let authResponse = try makeDecoder().decode(MeResponse.self, from: data)
        return authResponse.user
    }
    
    // MARK: - Users Endpoints
    
    func searchUsers(filters: UserFilters, page: Int = 1, limit: Int = 20) async throws -> UsersResponse {
        let endpoint = "/api/users"
        var components = URLComponents(string: "\(baseURL)\(endpoint)")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
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
        
        components.queryItems = queryItems
        
        // Log request
        LoggingService.shared.logAPIRequest(
            endpoint: "\(endpoint)?\(components.query ?? "")",
            method: "GET",
            headers: nil,
            body: nil
        )
        
        let startTime = Date()
        let (data, response) = try await session.data(from: components.url!)
        let duration = Date().timeIntervalSince(startTime)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            LoggingService.shared.logAPIError(
                endpoint: endpoint,
                method: "GET",
                statusCode: nil,
                error: APIError.networkError,
                responseData: data,
                additionalInfo: [
                    "filters": [
                        "role": filters.role?.rawValue ?? "nil",
                        "city": filters.city ?? "nil",
                        "sport": filters.sport?.rawValue ?? "nil",
                        "level": filters.level?.rawValue ?? "nil",
                        "position": filters.position ?? "nil"
                    ],
                    "pagination": ["page": page, "limit": limit]
                ]
            )
            throw APIError.networkError
        }
        
        // Log response
        LoggingService.shared.logAPIResponse(
            endpoint: endpoint,
            method: "GET",
            statusCode: httpResponse.statusCode,
            responseData: data,
            duration: duration
        )
        
        guard httpResponse.statusCode == 200 else {
            let error = APIError.invalidResponse
            LoggingService.shared.logAPIError(
                endpoint: endpoint,
                method: "GET",
                statusCode: httpResponse.statusCode,
                error: error,
                responseData: data,
                additionalInfo: [
                    "filters": [
                        "role": filters.role?.rawValue ?? "nil",
                        "city": filters.city ?? "nil",
                        "sport": filters.sport?.rawValue ?? "nil",
                        "level": filters.level?.rawValue ?? "nil",
                        "position": filters.position ?? "nil"
                    ],
                    "pagination": ["page": page, "limit": limit]
                ]
            )
            throw error
        }
        
        do {
            return try makeDecoder().decode(UsersResponse.self, from: data)
        } catch {
            print("🔴 Decoding error: \(error)")
            print("🔴 Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw error
        }
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
        
        return try makeDecoder().decode(OffersResponse.self, from: data)
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
        
        return try makeDecoder().decode(OfferDetailResponse.self, from: data)
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
        
        return try makeDecoder().decode(OfferResponse.self, from: data)
    }
    
    // MARK: - Applications Endpoints
    
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
        
        return try makeDecoder().decode(ApplicationResponse.self, from: data)
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
        
        return try makeDecoder().decode(UsersResponse.self, from: data)
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
        
        return try makeDecoder().decode(UserResponse.self, from: data)
    }

    // MARK: - Messages Endpoints
    func getConversations(token: String) async throws -> ConversationsResponse {
        let url = URL(string: "\(baseURL)/api/messages/conversations")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(ConversationsResponse.self, from: data)
    }
    
    func getMessages(conversationId: UUID, token: String) async throws -> MessagesResponse {
        let url = URL(string: "\(baseURL)/api/messages/conversations/\(conversationId)/messages")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(MessagesResponse.self, from: data)
    }
    
    func sendMessage(conversationId: UUID, content: String, token: String) async throws -> MessageResponse {
        let url = URL(string: "\(baseURL)/api/messages/conversations/\(conversationId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let body = SendMessageRequest(content: content)
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(MessageResponse.self, from: data)
    }

    func createConversation(participantId: UUID, token: String) async throws -> ConversationResponse {
        let url = URL(string: "\(baseURL)/api/messages/conversations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let body = CreateConversationRequest(participantId: participantId)
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(ConversationResponse.self, from: data)
    }
    
    // MARK: - Applications
    
    func getMyApplications(token: String) async throws -> ApplicationsResponse {
        let url = URL(string: "\(baseURL)/api/applications/my")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(ApplicationsResponse.self, from: data)
    }
    
    func getOfferApplications(offerId: UUID, token: String) async throws -> ApplicationsResponse {
        let url = URL(string: "\(baseURL)/api/applications/offer/\(offerId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(ApplicationsResponse.self, from: data)
    }
    
    // MARK: - My Offers
    
    func getMyOffers(token: String) async throws -> OffersResponse {
        let url = URL(string: "\(baseURL)/api/offers/my")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(OffersResponse.self, from: data)
    }
    
    // MARK: - User Profile
    
    func getUser(id: UUID, token: String) async throws -> UserResponse {
        let url = URL(string: "\(baseURL)/api/users/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try makeDecoder().decode(UserResponse.self, from: data)
    }
    
    // MARK: - Performance CV
    func getUserPerformance(userId: UUID, token: String, sport: String? = nil) async throws -> PerformanceSummary? {
        var components = URLComponents(string: "\(baseURL)/api/users/\(userId)/performance")!
        if let sport { components.queryItems = [URLQueryItem(name: "sport", value: sport)] }
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        struct Resp: Codable { let performance: PerformanceSummary? }
        return try makeDecoder().decode(Resp.self, from: data).performance
    }

    func updateUserPerformance(userId: UUID, summary: PerformanceSummary, token: String, sport: String? = nil) async throws {
        let url = URL(string: "\(baseURL)/api/users/\(userId)/performance")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        struct Req: Codable { let sport: String?; let performance: PerformanceSummary }
        request.httpBody = try JSONEncoder().encode(Req(sport: sport, performance: summary))
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Favorites Endpoints
    
    func checkFavorite(itemType: String, itemId: UUID, token: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/api/favorites/check/\(itemType)/\(itemId.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Logger pour debug
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Erreur checkFavorite - Status: \(httpResponse.statusCode), Response: \(errorString)")
            }
            throw APIError.invalidResponse
        }
        
        let result = try makeDecoder().decode(FavoriteCheckResponse.self, from: data)
        return result.isFavorite
    }
    
    func addFavorite(itemType: String, itemId: UUID, token: String) async throws {
        let url = URL(string: "\(baseURL)/api/favorites")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Encoder avec stratégie snake_case pour matcher le backend
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let body = AddFavoriteRequest(item_type: itemType, item_id: itemId)
        request.httpBody = try encoder.encode(body)
        
        // Log pour debug
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Body envoyé: \(bodyString)")
        }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Erreur addFavorite - Status: \(httpResponse.statusCode), Response: \(errorString)")
            }
            throw APIError.invalidResponse
        }
    }
    
    func removeFavorite(itemType: String, itemId: UUID, token: String) async throws {
        let url = URL(string: "\(baseURL)/api/favorites/\(itemType)/\(itemId.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Erreur removeFavorite - Status: \(httpResponse.statusCode), Response: \(errorString)")
            }
            throw APIError.invalidResponse
        }
    }
    
    func getFavoriteOffers(token: String) async throws -> OffersResponse {
        let url = URL(string: "\(baseURL)/api/favorites/offer")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let result = try makeDecoder().decode(FavoritesResponse.self, from: data)
        return OffersResponse(offers: result.favorites)
    }
    
    func getFavoriteUsers(type: String, token: String) async throws -> UsersResponse {
        let url = URL(string: "\(baseURL)/api/favorites/\(type)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let result = try makeDecoder().decode(FavoritesUsersResponse.self, from: data)
        // Créer une pagination par défaut car l'API des favoris ne retourne pas de pagination
        let defaultPagination = Pagination(page: 1, limit: result.favorites.count, total: result.favorites.count, pages: 1)
        return UsersResponse(users: result.favorites, pagination: defaultPagination)
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
}

struct OfferDetailResponse: Codable {
    let offer: Offer
}

struct OfferResponse: Codable {
    let message: String
    let offer: Offer
}


struct ApplicationResponse: Codable {
    let message: String
    let application: Application
}

struct UsersResponse: Codable {
    let users: [User]
    let pagination: Pagination
}


struct ConversationsResponse: Codable {
    let conversations: [Conversation]
}

struct MessagesResponse: Codable {
    let messages: [Message]
}

struct MessageResponse: Codable {
    let message: String
    let data: Message
}

struct SendMessageRequest: Codable {
    let content: String
}

struct CreateConversationRequest: Codable {
    let participantId: UUID
}

struct ConversationResponse: Codable {
    let message: String
    let conversation: Conversation
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

struct ErrorResponse: Codable {
    let error: String
}

struct UserFilters {
    let role: UserRole?
    let sport: Sport?
    let city: String?
    let level: SkillLevel?
    let position: String?
}

struct ApplicationsResponse: Codable {
    let applications: [Application]
}

struct UserResponse: Codable {
    let user: User
}

struct FavoriteCheckResponse: Codable {
    let isFavorite: Bool
}

struct AddFavoriteRequest: Codable {
    let item_type: String
    let item_id: UUID
}

struct FavoritesResponse: Codable {
    let favorites: [Offer]
}

struct FavoritesUsersResponse: Codable {
    let favorites: [User]
}


// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidResponse
    case invalidCredentials
    case networkError
    case decodingError
    case serverError(String)
    
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
        case .serverError(let message):
            return message
        }
    }
}
