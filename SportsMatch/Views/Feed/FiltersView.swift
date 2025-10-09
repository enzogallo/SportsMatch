//
//  FiltersView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSport: Sport?
    @State private var selectedLevel: SkillLevel?
    @State private var selectedPosition = ""
    @State private var city = ""
    @State private var maxDistance: Double = 50
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Sport
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sport")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(Sport.allCases, id: \.self) { sport in
                                SportFilterChip(
                                    sport: sport,
                                    isSelected: selectedSport == sport
                                ) {
                                    selectedSport = selectedSport == sport ? nil : sport
                                }
                            }
                        }
                    }
                    
                    // Niveau
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Niveau")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(SkillLevel.allCases, id: \.self) { level in
                                LevelFilterChip(
                                    level: level,
                                    isSelected: selectedLevel == level
                                ) {
                                    selectedLevel = selectedLevel == level ? nil : level
                                }
                            }
                        }
                    }
                    
                    // Position
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Position")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Ex: Gardien, Attaquant, Milieu...", text: $selectedPosition)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Ville
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ville")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Ex: Paris, Lyon, Marseille...", text: $city)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Distance maximale
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Distance maximale")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("0 km")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                Spacer()
                                
                                Text("\(Int(maxDistance)) km")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryBlue)
                                
                                Spacer()
                                
                                Text("100 km")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Slider(value: $maxDistance, in: 0...100, step: 5)
                                .accentColor(.primaryBlue)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Appliquer") {
                        // Appliquer les filtres
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct SportFilterChip: View {
    let sport: Sport
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(sport.emoji)
                    .font(.title3)
                
                Text(sport.displayName)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryBlue : Color.surfaceSecondary)
            )
        }
    }
}

struct LevelFilterChip: View {
    let level: SkillLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(level.displayName)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.primaryBlue : Color.surfaceSecondary)
                )
        }
    }
}

#Preview {
    FiltersView()
}
