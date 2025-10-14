//
//  ConversationView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import SwiftUI

struct ConversationView: View {
    let conversation: Conversation
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage { Text(errorMessage).foregroundColor(.error).padding(.top, 8) }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            HStack {
                                if isOwn(msg) { Spacer(minLength: 40) }
                                Text(msg.content)
                                    .font(.callout)
                                    .padding(10)
                                    .background(isOwn(msg) ? Color.primaryBlue : Color.surfaceSecondary)
                                    .foregroundColor(isOwn(msg) ? .white : .textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                if !isOwn(msg) { Spacer(minLength: 40) }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            
            Divider()
            
            HStack(spacing: 8) {
                TextField("Votre message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .lineLimit(1...4)
                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: isSending ? "hourglass" : "paperplane.fill")
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.surface)
        }
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            Group { if isLoading { ProgressView().scaleEffect(1.2) } }
        )
        .task { await load() }
    }
    
    private func isOwn(_ message: Message) -> Bool {
        // Comparer avec l'utilisateur connecté
        guard let currentUserId = authService.currentUser?.id else { return false }
        return message.senderId == currentUserId
    }
    
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = authService.getStoredToken() else { throw APIError.invalidCredentials }
            let resp = try await api.getMessages(conversationId: conversation.id, token: token)
            messages = resp.messages
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func send() async {
        let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        isSending = true
        errorMessage = nil
        do {
            guard let token = authService.getStoredToken(),
                  let senderId = authService.currentUser?.id else { throw APIError.invalidCredentials }
            let resp = try await api.sendMessage(conversationId: conversation.id, senderId: senderId, content: content, token: token)
            messages.append(resp.data)
            inputText = ""
            isSending = false
        } catch {
            errorMessage = error.localizedDescription
            isSending = false
        }
    }
}

#Preview {
    NavigationView {
        ConversationView(conversation: Conversation(
            id: UUID(),
            participantIds: [UUID(), UUID()],
            lastMessage: nil,
            lastActivityAt: Date(),
            unreadCount: 0
        ))
    }
}



