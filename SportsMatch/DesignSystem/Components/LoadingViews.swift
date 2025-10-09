//
//  LoadingViews.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryBlue)
            
            Text(message)
                .font(.callout)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

struct LoadingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec shimmer
            HStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 120, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            // Titre shimmer
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.surfaceSecondary)
                .frame(height: 20)
            
            // Description shimmer
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 200, height: 14)
            }
            
            // Actions shimmer
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 80, height: 32)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 80, height: 32)
            }
        }
        .padding(16)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ShimmerEffect: View {
    @State private var isAnimating = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.surfaceSecondary,
                Color.surfaceSecondary.opacity(0.3),
                Color.surfaceSecondary
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white,
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .offset(x: isAnimating ? 200 : -200)
        .animation(
            Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(message)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .offset(y: isShowing ? 0 : -100)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

enum ToastType {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return .success
        case .error:
            return .error
        case .warning:
            return .warning
        case .info:
            return .info
        }
    }
}

struct PullToRefreshView: View {
    let onRefresh: () async -> Void
    @State private var isRefreshing = false
    
    var body: some View {
        VStack {
            if isRefreshing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.primaryBlue)
                    
                    Text("Actualisation...")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    func refresh() async {
        isRefreshing = true
        await onRefresh()
        isRefreshing = false
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView(message: "Chargement des offres...")
        
        LoadingCard()
        
        ToastView(
            message: "Candidature envoyée avec succès !",
            type: .success,
            isShowing: .constant(true)
        )
    }
}
