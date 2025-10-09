//
//  LoginView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Logo et titre
                VStack(spacing: 16) {
                    Image(systemName: "sportscourt")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryBlue)
                    
                    Text("SportsMatch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Trouve ton équipe. Trouve ton match.")
                        .font(.callout)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Formulaire de connexion
                VStack(spacing: 20) {
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
                    
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.error)
                            .padding(.horizontal)
                    }
                }
                
                // Boutons d'action
                VStack(spacing: 16) {
                    Button("Se connecter") {
                        Task {
                            await authService.signIn(email: email, password: password)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: email.isEmpty || password.isEmpty))
                    .disabled(authService.isLoading)
                    
                    Button("Créer un compte") {
                        showingSignUp = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color.background)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Navigation vers l'app principale
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.surfaceSecondary, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}
