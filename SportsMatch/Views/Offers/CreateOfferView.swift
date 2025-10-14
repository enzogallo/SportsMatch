//
//  CreateOfferView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct CreateOfferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var offerService = OfferService()
    @EnvironmentObject var authService: AuthService
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedSport: Sport = .football
    @State private var position = ""
    @State private var selectedLevel: SkillLevel = .intermediate
    @State private var selectedType: OfferType = .recruitment
    @State private var location = ""
    @State private var city = ""
    @State private var minAge = ""
    @State private var maxAge = ""
    @State private var isUrgent = false
    @State private var maxApplications = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Informations de base
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informations de base")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Titre de l'offre")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("Ex: Recherche gardien de but", text: $title)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("Décrivez l'offre, les conditions, les horaires...", text: $description, axis: .vertical)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sport")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                Picker("Sport", selection: $selectedSport) {
                                    ForEach(Sport.allCases, id: \.self) { sport in
                                        Text(sport.displayName).tag(sport)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(16)
                                .background(Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.surfaceSecondary, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Détails de l'offre
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Détails de l'offre")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Position recherchée")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("Ex: Gardien, Attaquant, Milieu...", text: $position)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Niveau requis")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                Picker("Niveau", selection: $selectedLevel) {
                                    ForEach(SkillLevel.allCases, id: \.self) { level in
                                        Text(level.displayName).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type d'offre")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                Picker("Type", selection: $selectedType) {
                                    ForEach(OfferType.allCases, id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Localisation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Localisation")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ville")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("Ex: Paris, Lyon, Marseille...", text: $city)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Lieu précis")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("Ex: Stade Municipal, Gymnase des Sports...", text: $location)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Critères additionnels
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Critères additionnels")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Âge minimum")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    TextField("18", text: $minAge)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Âge maximum")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    TextField("35", text: $maxAge)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Candidatures maximum")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                TextField("50", text: $maxApplications)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            Toggle("Offre urgente", isOn: $isUrgent)
                                .toggleStyle(SwitchToggleStyle(tint: .primaryBlue))
                        }
                    }
                    .padding(20)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Boutons d'action
                    VStack(spacing: 12) {
                        Button("Publier l'offre") {
                            createOffer()
                        }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
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
            .navigationTitle("Créer une offre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !city.isEmpty &&
        !location.isEmpty
    }
    
    private func createOffer() {
        isSubmitting = true
        
        guard let clubId = authService.currentUser?.id else { isSubmitting = false; return }
        let offer = Offer(
            clubId: clubId,
            title: title,
            description: description,
            sport: selectedSport,
            location: location,
            city: city
        )
        
        Task {
            guard let token = authService.getStoredToken() else {
                print("❌ Aucun token d'authentification trouvé")
                isSubmitting = false
                return
            }
            
            await offerService.createOffer(offer, token: token)
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    CreateOfferView()
}
