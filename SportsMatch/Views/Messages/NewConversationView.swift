//
//  NewConversationView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import SwiftUI

struct NewConversationView: View {
    let participant: User?
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let participant = participant {
                    // Header avec info du participant
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.surfaceSecondary)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: participant.role == .player ? "person.fill" : "building.2.fill")
                                    .foregroundColor(.textTertiary)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(participant.name)
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text(participant.role.displayName)
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Champ de message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Votre message")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Écrivez votre message...", text: $message, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal, 20)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.error)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                } else {
                    Text("Participant non trouvé")
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
            }
            .navigationTitle("Nouveau message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        onDismiss()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Envoyer") {
                        Task { await sendMessage() }
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }
            }
        }
    }
    
    private func sendMessage() async {
        guard let participant = participant else { return }
        isSending = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "auth_token") else { throw APIError.invalidCredentials }
            let conversation = try await api.createConversation(participantId: participant.id, token: token)
            
            // Si on a un message, l'envoyer
            if !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                _ = try await api.sendMessage(
                    conversationId: conversation.conversation.id,
                    content: message,
                    token: token
                )
            }
            
            // Fermer la vue
            onDismiss()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSending = false
    }
}

#Preview {
    NewConversationView(
        participant: User(
            id: UUID(),
            email: "test@example.com",
            name: "Test User",
            role: .player
        ),
        onDismiss: {}
    )
}
