//
//  ConnectionStatusView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct ConnectionStatusView: View {
    @StateObject private var connectionService = ConnectionService()
    
    var body: some View {
        HStack(spacing: 8) {
            // Indicateur de statut
            Circle()
                .fill(connectionService.isConnected ? Color.success : Color.error)
                .frame(width: 8, height: 8)
                .scaleEffect(connectionService.isConnecting ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                          value: connectionService.isConnecting)
            
            // Texte de statut
            Text(connectionService.isConnected ? "Connecté" : "Déconnecté")
                .font(.caption)
                .foregroundColor(connectionService.isConnected ? .success : .error)
            
            // Bouton de reconnexion si déconnecté
            if !connectionService.isConnected && !connectionService.isConnecting {
                Button("Reconnecter") {
                    Task {
                        await connectionService.checkConnection()
                    }
                }
                .font(.caption2)
                .foregroundColor(.primaryBlue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.surface)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            Task {
                await connectionService.checkConnection()
            }
        }
    }
}

#Preview {
    VStack {
        ConnectionStatusView()
        Spacer()
    }
    .padding()
    .background(Color.background)
}
