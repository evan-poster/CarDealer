//
//  SignInView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeTokens) private var themeTokens
    @StateObject private var authManager = AuthenticationManager()
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: themeTokens.spacing * 2) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: themeTokens.spacing) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("CarDealer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Sign In Form
                VStack(spacing: themeTokens.spacing) {
                    VStack(alignment: .leading, spacing: themeTokens.spacing / 2) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: themeTokens.spacing / 2) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Sign In") {
                        signIn()
                    }
                    .buttonStyle(PillButtonStyle())
                    .disabled(email.isEmpty || password.isEmpty)
                }
                .cardStyle()
                
                Spacer()
                
                // Demo credentials hint
                VStack(spacing: 4) {
                    Text("Demo Credentials:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Any email and password will work")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
            }
            .padding(themeTokens.spacing)
            .navigationTitle("Welcome")
            .alert("Sign In Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .fullScreenCover(isPresented: $authManager.isAuthenticated) {
            MainTabView()
                .environmentObject(authManager)
        }
    }
    
    private func signIn() {
        let success = authManager.signIn(email: email, password: password, modelContext: modelContext)
        
        if !success {
            errorMessage = "Please enter a valid email and password"
            showError = true
        }
    }
}

#Preview {
    SignInView()
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}