//
//  ProfileView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeTokens) private var themeTokens
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var displayName = ""
    @State private var avatarURL = ""
    @State private var isEditing = false
    @State private var showSignOutConfirmation = false
    
    @Query private var orders: [Order]
    @Query private var likes: [Like]
    
    var userOrders: [Order] {
        guard let currentUser = authManager.currentUser else { return [] }
        return orders.filter { $0.userID == currentUser.id }
    }
    
    var userLikes: [Like] {
        guard let currentUser = authManager.currentUser else { return [] }
        return likes.filter { $0.userID == currentUser.id }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .formLabel, spacing: themeTokens.spacing) {
                    // Profile Header
                    VStack(spacing: themeTokens.spacing) {
                        // Avatar
                        AsyncImage(url: URL(string: authManager.currentUser?.avatarURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 40))
                                )
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .cardStyle()
                    
                    // Profile Information
                    VStack(alignment: .formLabel, spacing: themeTokens.spacing) {
                        HStack {
                            Text("Profile Information")
                                .font(.headline)
                                .alignmentGuide(.formLabel) { d in d[.leading] }
                            
                            Spacer()
                            
                            Button(isEditing ? "Save" : "Edit") {
                                if isEditing {
                                    saveProfile()
                                } else {
                                    loadCurrentProfile()
                                }
                                isEditing.toggle()
                            }
                            .foregroundColor(.accentColor)
                        }
                        
                        if isEditing {
                            FormField(label: "Display Name", text: $displayName, placeholder: "Enter your display name")
                            FormField(label: "Avatar URL", text: $avatarURL, placeholder: "https://example.com/avatar.jpg")
                        } else {
                            ProfileInfoRow(label: "Display Name", value: authManager.currentUser?.displayName ?? "Not set")
                            ProfileInfoRow(label: "Avatar URL", value: authManager.currentUser?.avatarURL.isEmpty == false ? "Set" : "Not set")
                        }
                    }
                    .cardStyle()
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: themeTokens.spacing) {
                        Text("Statistics")
                            .font(.headline)
                        
                        HStack(spacing: themeTokens.spacing) {
                            StatCard(title: "Purchases", value: "\(userOrders.count)", icon: "cart.fill")
                            StatCard(title: "Liked Cars", value: "\(userLikes.count)", icon: "heart.fill")
                        }
                    }
                    .cardStyle()
                    
                    // Recent Orders
                    if !userOrders.isEmpty {
                        VStack(alignment: .leading, spacing: themeTokens.spacing) {
                            Text("Recent Purchases")
                                .font(.headline)
                            
                            ForEach(userOrders.prefix(3), id: \.id) { order in
                                OrderRowView(order: order)
                            }
                        }
                        .cardStyle()
                    }
                    
                    // Sign Out Button
                    Button("Sign Out") {
                        showSignOutConfirmation = true
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: themeTokens.cornerRadius)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
                .padding(themeTokens.spacing)
            }
            .navigationTitle("Profile")
            .onAppear {
                loadCurrentProfile()
            }
            .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let currentUser = authManager.currentUser else { return }
        displayName = currentUser.displayName
        avatarURL = currentUser.avatarURL
    }
    
    private func saveProfile() {
        guard let currentUser = authManager.currentUser else { return }
        
        currentUser.displayName = displayName.isEmpty ? currentUser.email.components(separatedBy: "@").first ?? "User" : displayName
        currentUser.avatarURL = avatarURL
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving profile: \(error)")
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .formLabel, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .alignmentGuide(.formLabel) { d in d[.leading] }
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.body)
                    .alignmentGuide(.formLabel) { d in d[.leading] }
                Spacer()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    @Environment(\.themeTokens) private var themeTokens
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: themeTokens.cornerRadius)
                .fill(Color(.systemGray6))
        )
    }
}

struct OrderRowView: View {
    let order: Order
    @Query private var cars: [Car]
    
    var car: Car? {
        cars.first { $0.id == order.carID }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let car = car {
                    Text("\(car.make) \(car.model)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text("Unknown Car")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text(order.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(order.price, specifier: "%.0f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}