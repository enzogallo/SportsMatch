//
//  MyApplicationsView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import SwiftUI

struct MyApplicationsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var applications: [Application] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    Spacer()
                    ProgressView("Chargement des candidatures...")
                        .foregroundColor(.textSecondary)
                    Spacer()
                } else if applications.isEmpty {
                    EmptyApplicationsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(applications) { application in
                                ApplicationCard(application: application)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Mes candidatures")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
        }
        .overlay(
            Group {
                if let errorMessage { Text(errorMessage).foregroundColor(.error) }
            }
        )
        .task {
            await loadApplications()
        }
    }
    
    private func loadApplications() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let token = authService.getStoredToken() else { throw APIError.invalidCredentials }
            let response = try await api.getMyApplications(token: token)
            applications = response.applications
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct ApplicationCard: View {
    let application: Application
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.offerTitle)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(application.clubName)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                ApplicationStatusBadge(status: application.status)
            }
            
            if let message = application.message, !message.isEmpty {
                Text(message)
                    .font(.callout)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text("Candidaté le \(application.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                if application.status == .pending {
                    Text("En attente")
                        .font(.caption)
                        .foregroundColor(.warning)
                }
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ApplicationStatusBadge: View {
    let status: ApplicationStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .warning
        case .accepted:
            return .success
        case .rejected:
            return .error
        case .withdrawn:
            return .textTertiary
        }
    }
}

struct EmptyApplicationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("Aucune candidature")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Vos candidatures aux offres apparaîtront ici.")
                .font(.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyApplicationsView()
        .environmentObject(AuthService())
}
