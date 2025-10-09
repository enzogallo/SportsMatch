//
//  ApplicationView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct ApplicationView: View {
    let offer: Offer
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Résumé de l'offre
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Candidature pour")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 12) {
                            Text(offer.sport.emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(offer.title)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("\(offer.city), \(offer.location)")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Message de candidature
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Message de candidature")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pourquoi souhaitez-vous rejoindre cette équipe ?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            TextField("Parlez de votre expérience, vos motivations...", text: $message, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(5...10)
                        }
                        
                        Text("Ce message sera envoyé au club avec votre candidature.")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    
                    // Informations importantes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informations importantes")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "clock", text: "Vous recevrez une réponse dans les 48h")
                            InfoRow(icon: "message", text: "Une fois accepté, vous pourrez échanger avec le club")
                            InfoRow(icon: "person.2", text: "Votre profil sera visible par le club")
                        }
                    }
                    .padding(16)
                    .background(Color.info.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Boutons d'action
                    VStack(spacing: 12) {
                        Button("Envoyer ma candidature") {
                            submitApplication()
                        }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: message.isEmpty))
                        .disabled(isSubmitting)
                        
                        Button("Annuler") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Candidature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Candidature envoyée !", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Votre candidature a été envoyée au club. Vous recevrez une réponse dans les 48h.")
        }
    }
    
    private func submitApplication() {
        isSubmitting = true
        
        // Simulation d'envoi de candidature
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showingSuccess = true
        }
    }
}

#Preview {
    ApplicationView(offer: Offer(
        clubId: UUID(),
        title: "Recherche gardien de but",
        description: "Notre équipe de football amateur cherche un gardien de but expérimenté.",
        sport: .football,
        location: "Stade Municipal",
        city: "Paris"
    ))
}
