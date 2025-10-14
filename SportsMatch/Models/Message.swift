//
//  Message.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let content: String
    let type: MessageType
    var isRead: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), conversationId: UUID, senderId: UUID, content: String, type: MessageType = .text) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.content = content
        self.type = type
        self.isRead = false
        self.createdAt = Date()
    }
}

enum MessageType: String, CaseIterable, Codable {
    case text = "text"
    case image = "image"
    case application = "application"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .text:
            return "Texte"
        case .image:
            return "Image"
        case .application:
            return "Candidature"
        case .system:
            return "Système"
        }
    }
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    let participantIds: [UUID]
    let lastMessage: Message?
    let lastActivityAt: Date
    var unreadCount: Int
    
    // Computed property for display
    var participantName: String? {
        // This would be populated from the participant data
        return participantIds.first.map { "Participant #\($0.uuidString.prefix(8))" }
    }
    
    init(id: UUID = UUID(), participantIds: [UUID]) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessage = nil
        self.lastActivityAt = Date()
        self.unreadCount = 0
    }
}
