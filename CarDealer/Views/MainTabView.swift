//
//  MainTabView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            CarFeedView()
                .tabItem {
                    Image(systemName: "car.2.fill")
                    Text("Browse")
                }
            
            SellCarView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Sell")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
        .onAppear {
            // Load current user immediately when MainTabView appears
            if authManager.currentUser == nil {
                authManager.loadCurrentUser(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}