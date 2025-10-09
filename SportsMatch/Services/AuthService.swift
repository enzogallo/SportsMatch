//
//  AuthService.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    private let tokenKey = "auth_token"
    
    init() {
        // Vérifier si un utilisateur est déjà connecté
        checkAuthStatus()
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            
            // Sauvegarder le token
            UserDefaults.standard.set(response.token, forKey: tokenKey)
            
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signUp(email: String, password: String, name: String, role: UserRole) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.register(email: email, password: password, name: name, role: role)
            
            // Sauvegarder le token
            UserDefaults.standard.set(response.token, forKey: tokenKey)
            
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signOut() {
        // Supprimer le token
        UserDefaults.standard.removeObject(forKey: tokenKey)
        
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateProfile(_ user: User) async {
        isLoading = true
        
        do {
            guard let token = getStoredToken() else {
                throw APIError.invalidCredentials
            }
            
            let updateRequest = UpdateUserRequest(
                name: user.name,
                age: user.age,
                city: user.city,
                sports: user.sports?.map { $0.rawValue },
                position: user.position,
                level: user.level?.rawValue,
                bio: user.bio,
                profile_image_url: user.profileImageURL,
                status: user.status?.rawValue,
                club_name: user.clubName,
                club_logo_url: user.clubLogoURL,
                club_description: user.clubDescription,
                contact_email: user.contactEmail,
                contact_phone: user.contactPhone,
                sports_offered: user.sportsOffered?.map { $0.rawValue },
                location: user.location
            )
            
            let response = try await apiService.updateUser(id: user.id, user: updateRequest, token: token)
            currentUser = response.user
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func checkAuthStatus() {
        guard let token = getStoredToken() else {
            isAuthenticated = false
            return
        }
        
        // Vérifier si le token est valide en récupérant le profil utilisateur
        Task {
            do {
                let user = try await apiService.getCurrentUser(token: token)
                await MainActor.run {
                    currentUser = user
                    isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    // Token invalide, déconnecter l'utilisateur
                    signOut()
                }
            }
        }
    }
    
    private func getStoredToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
}
