//
//  CarFeedView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct CarFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.apiBase) private var apiBase
    @Environment(\.themeTokens) private var themeTokens
    @EnvironmentObject var authManager: AuthenticationManager
    
    @Query private var cars: [Car]
    @StateObject private var carService = CarService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: themeTokens.spacing, pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(cars, id: \.id) { car in
                            NavigationLink(destination: CarDetailView(car: car)) {
                                CarRowView(car: car)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        if carService.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading cars...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, themeTokens.spacing)
                            .padding(.vertical, themeTokens.spacing / 2)
                            .background(Color(.systemBackground))
                        }
                    }
                }
                .padding(.horizontal, themeTokens.spacing)
            }
            .navigationTitle("Browse Cars")
            .refreshable {
                await carService.fetchCars(apiBase: apiBase, modelContext: modelContext)
            }
            .task {
                authManager.loadCurrentUser(modelContext: modelContext)
                if cars.isEmpty {
                    await carService.fetchCars(apiBase: apiBase, modelContext: modelContext)
                }
            }
            .alert("Error", isPresented: .constant(carService.errorMessage != nil)) {
                Button("OK") {
                    carService.errorMessage = nil
                }
            } message: {
                if let errorMessage = carService.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

struct CarRowView: View {
    let car: Car
    @Environment(\.themeTokens) private var themeTokens
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var isLiked = false
    
    var body: some View {
        HStack(spacing: themeTokens.spacing) {
            // Car Image
            AsyncImage(url: URL(string: car.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: themeTokens.cornerRadius)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "car.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    )
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: themeTokens.cornerRadius))
            
            // Car Details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(car.make) \(car.model)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(car.year)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(car.price, specifier: "%.0f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Button(action: toggleLike) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .secondary)
                            .font(.title3)
                    }
                }
            }
            
            Spacer()
        }
        .cardStyle()
        .onAppear {
            checkIfLiked()
        }
    }
    
    private func toggleLike() {
        guard let currentUser = authManager.currentUser else { return }
        
        let carID = car.id
        let userID = currentUser.id
        
        if isLiked {
            // Remove like
            let fetchDescriptor = FetchDescriptor<Like>(
                predicate: #Predicate<Like> { like in
                    like.carID == carID && like.userID == userID
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
            let newLike = Like(carID: carID, userID: userID)
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
        
        let carID = car.id
        let userID = currentUser.id
        
        let fetchDescriptor = FetchDescriptor<Like>(
            predicate: #Predicate<Like> { like in
                like.carID == carID && like.userID == userID
            }
        )
        
        do {
            let likes = try modelContext.fetch(fetchDescriptor)
            isLiked = !likes.isEmpty
        } catch {
            print("Error checking like status: \(error)")
        }
    }
}

#Preview {
    CarFeedView()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}