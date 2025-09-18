//
//  CarDetailView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct CarDetailView: View {
    let car: Car
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeTokens) private var themeTokens
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var isLiked = false
    @State private var showBuyConfirmation = false
    @State private var showPurchaseSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: themeTokens.spacing) {
                // Car Image with Price Badge
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: car.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "car.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 40))
                            )
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: themeTokens.cornerRadius))
                    
                    // Price Badge
                    Text("$\(car.price, specifier: "%.0f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            PriceBadgeShape()
                                .fill(Color.accentColor)
                        )
                        .offset(x: -themeTokens.spacing, y: themeTokens.spacing)
                }
                
                // Car Information
                VStack(alignment: .leading, spacing: themeTokens.spacing) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(car.make) \(car.model)")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Year: \(car.year)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: toggleLike) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .secondary)
                                .font(.title2)
                        }
                    }
                    
                    Divider()
                    
                    // Specifications
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specifications")
                            .font(.headline)
                        
                        SpecificationRow(label: "Make", value: car.make)
                        SpecificationRow(label: "Model", value: car.model)
                        SpecificationRow(label: "Year", value: String(car.year))
                        SpecificationRow(label: "Price", value: "$\(car.price, specifier: "%.0f")")
                        
                        if car.isFromAPI {
                            SpecificationRow(label: "Source", value: "Dealer Inventory")
                        } else {
                            SpecificationRow(label: "Source", value: "Private Seller")
                        }
                    }
                    
                    Spacer(minLength: themeTokens.spacing * 2)
                    
                    // Action Buttons
                    VStack(spacing: themeTokens.spacing) {
                        Button("Buy Now") {
                            showBuyConfirmation = true
                        }
                        .buttonStyle(PillButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        Button("Contact Seller") {
                            // Placeholder for contact functionality
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                    }
                }
                .cardStyle()
            }
            .padding(themeTokens.spacing)
        }
        .navigationTitle("Car Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkIfLiked()
        }
        .confirmationDialog("Purchase Confirmation", isPresented: $showBuyConfirmation) {
            Button("Buy for $\(car.price, specifier: "%.0f")") {
                purchaseCar()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to purchase this \(car.make) \(car.model)?")
        }
        .alert("Purchase Successful!", isPresented: $showPurchaseSuccess) {
            Button("OK") { }
        } message: {
            Text("You have successfully purchased the \(car.make) \(car.model) for $\(car.price, specifier: "%.0f")")
        }
    }
    
    private func toggleLike() {
        guard let currentUser = authManager.currentUser else { return }
        
        if isLiked {
            // Remove like
            let fetchDescriptor = FetchDescriptor<Like>(
                predicate: #Predicate<Like> { like in
                    like.carID == car.id && like.userID == currentUser.id
                }
            )
            
            do {
                let likes = try modelContext.fetch(fetchDescriptor)
                for like in likes {
                    modelContext.delete(like)
                }
                try modelContext.save()
                isLiked = false
            } catch {
                print("Error removing like: \(error)")
            }
        } else {
            // Add like
            let newLike = Like(carID: car.id, userID: currentUser.id)
            modelContext.insert(newLike)
            
            do {
                try modelContext.save()
                isLiked = true
            } catch {
                print("Error adding like: \(error)")
            }
        }
    }
    
    private func checkIfLiked() {
        guard let currentUser = authManager.currentUser else { return }
        
        let fetchDescriptor = FetchDescriptor<Like>(
            predicate: #Predicate<Like> { like in
                like.carID == car.id && like.userID == currentUser.id
            }
        )
        
        do {
            let likes = try modelContext.fetch(fetchDescriptor)
            isLiked = !likes.isEmpty
        } catch {
            print("Error checking like status: \(error)")
        }
    }
    
    private func purchaseCar() {
        guard let currentUser = authManager.currentUser else { return }
        
        let newOrder = Order(carID: car.id, userID: currentUser.id, price: car.price)
        modelContext.insert(newOrder)
        
        do {
            try modelContext.save()
            showPurchaseSuccess = true
        } catch {
            print("Error creating order: \(error)")
        }
    }
}

struct SpecificationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationView {
        CarDetailView(car: Car(
            make: "Toyota",
            model: "Camry",
            year: 2023,
            price: 28500,
            imageURL: "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400"
        ))
    }
    .environmentObject(AuthenticationManager())
    .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}