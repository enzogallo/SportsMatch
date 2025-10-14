//
//  MessagesView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct MessagesView: View {
    @State private var conversations: [Conversation] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingNewConversation = false
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre de recherche
                if !conversations.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textTertiary)
                        
                        TextField("Rechercher dans les messages...", text: $searchText)
                            .font(.callout)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                
                // Liste des conversations
                if conversations.isEmpty {
                    EmptyMessagesView()
                } else {
                    NavigationView {
                        ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(conversations) { conversation in
                                    NavigationLink(destination: ConversationView(conversationId: conversation.id)) {
                                        ConversationRow(conversation: conversation)
                                    }
                            }
                        }
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewConversation = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .overlay(
            Group {
                if isLoading { ProgressView().scaleEffect(1.2) }
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task {
            await loadConversations()
        }
        .sheet(isPresented: $showingNewConversation) {
            NewConversationView(
                participant: nil,
                onDismiss: {
                    Task {
                        await loadConversations()
                    }
                }
            )
        }
    }
    
    private func loadConversations() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = UserDefaults.standard.string(forKey: "auth_token") else { throw APIError.invalidCredentials }
            let response = try await api.getConversations(token: token)
            conversations = response.conversations
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo de profil
            Circle()
                .fill(Color.surfaceSecondary)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.textTertiary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.participantName ?? "Contact")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text(conversation.lastActivityAt, style: .time)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                
                HStack {
                    Text(conversation.lastMessage?.content ?? "Aucun message")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.primaryBlue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.surface)
        .overlay(
            Rectangle()
                .fill(Color.surfaceSecondary)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct EmptyMessagesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("Aucun message")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Vos conversations avec les clubs et joueurs apparaîtront ici.")
                .font(.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MessagesView()
}
