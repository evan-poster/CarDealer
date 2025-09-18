//
//  SellCarView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct SellCarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeTokens) private var themeTokens
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var price = ""
    @State private var imageURL = ""
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .formLabel, spacing: themeTokens.spacing) {
                    Text("Create a new car listing")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, themeTokens.spacing)
                    
                    // Form Fields with Custom Alignment
                    FormField(label: "Make", text: $make, placeholder: "e.g., Toyota")
                    FormField(label: "Model", text: $model, placeholder: "e.g., Camry")
                    FormField(label: "Year", text: $year, placeholder: "e.g., 2023")
                        .keyboardType(.numberPad)
                    FormField(label: "Price", text: $price, placeholder: "e.g., 25000")
                        .keyboardType(.decimalPad)
                    FormField(label: "Image URL", text: $imageURL, placeholder: "https://example.com/image.jpg")
                        .keyboardType(.URL)
                    
                    Spacer(minLength: themeTokens.spacing * 2)
                    
                    // Action Buttons
                    VStack(spacing: themeTokens.spacing) {
                        Button("List Car for Sale") {
                            createListing()
                        }
                        .buttonStyle(PillButtonStyle())
                        .frame(maxWidth: .infinity)
                        .disabled(!isFormValid)
                        
                        Button("Clear Form") {
                            clearForm()
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .cardStyle()
                .padding(themeTokens.spacing)
            }
            .navigationTitle("Sell Your Car")
            .alert("Listing Created!", isPresented: $showSuccess) {
                Button("OK") {
                    clearForm()
                }
            } message: {
                Text("Your \(make) \(model) has been listed for sale!")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !make.isEmpty && !model.isEmpty && !year.isEmpty && !price.isEmpty &&
        Int(year) != nil && Double(price) != nil
    }
    
    private func createListing() {
        guard let currentUser = authManager.currentUser,
              let yearInt = Int(year),
              let priceDouble = Double(price) else {
            errorMessage = "Please check your input values"
            showError = true
            return
        }
        
        let newCar = Car(
            make: make,
            model: model,
            year: yearInt,
            price: priceDouble,
            imageURL: imageURL.isEmpty ? "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400" : imageURL,
            sellerID: currentUser.id,
            isFromAPI: false
        )
        
        modelContext.insert(newCar)
        
        do {
            try modelContext.save()
            showSuccess = true
        } catch {
            errorMessage = "Failed to create listing: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func clearForm() {
        make = ""
        model = ""
        year = ""
        price = ""
        imageURL = ""
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    @Environment(\.themeTokens) private var themeTokens
    
    var body: some View {
        VStack(alignment: .formLabel, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .alignmentGuide(.formLabel) { d in d[.leading] }
                Spacer()
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .alignmentGuide(.formLabel) { d in d[.leading] }
        }
    }
}

extension View {
    func keyboardType(_ type: UIKeyboardType) -> some View {
        if let textField = self as? TextField<Text> {
            return AnyView(textField.keyboardType(type))
        }
        return AnyView(self)
    }
}

#Preview {
    SellCarView()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}