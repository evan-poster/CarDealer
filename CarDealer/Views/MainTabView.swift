//
//  MainTabView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI

struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}