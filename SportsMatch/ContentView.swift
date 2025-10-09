//
//  ContentView.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "sportscourt")
                .imageScale(.large)
                .foregroundColor(.primaryBlue)
            Text("SportsMatch")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            Text("Trouve ton équipe. Trouve ton match.")
                .font(.callout)
                .foregroundColor(.textSecondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
