//
//  SignUpView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var selectedRole: UserRole = .player
    @State private var showingRoleSelection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Créer un compte")
                            .font(.title1)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Rejoignez la communauté SportsMatch")
                            .font(.callout)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 20)
                    
                    // Formulaire d'inscription
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nom complet")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            TextField("Votre nom", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            TextField("votre@email.com", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mot de passe")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            SecureField("••••••••", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmer le mot de passe")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            SecureField("••••••••", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Sélection du rôle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Je suis un...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    Button(action: {
                                        selectedRole = role
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: role == .player ? "person.fill" : "building.2.fill")
                                                .font(.title3)
                                            
                                            Text(role.displayName)
                                                .font(.callout)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedRole == role ? .white : .primaryBlue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedRole == role ? Color.primaryBlue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.primaryBlue, lineWidth: 2)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.error)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Boutons d'action
                    VStack(spacing: 16) {
                        Button("Créer mon compte") {
                            Task {
                                await authService.signUp(
                                    email: email,
                                    password: password,
                                    name: name,
                                    role: selectedRole
                                )
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
                        .disabled(authService.isLoading)
                        
                        Button("Annuler") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
}

#Preview {
    SignUpView()
}
