//
//  AuthenticationManager.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let userDefaultsKey = "CarDealerAuthToken"
    private let userEmailKey = "CarDealerUserEmail"
    
    init() {
        checkAuthenticationStatus()
    }
    
    func signIn(email: String, password: String, modelContext: ModelContext) -> Bool {
        // Simple validation - in a real app, this would be server-side
        guard !email.isEmpty, !password.isEmpty, email.contains("@") else {
            return false
        }
        
        // Store mock token in UserDefaults
        UserDefaults.standard.set("mock_token_\(UUID().uuidString)", forKey: userDefaultsKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        
        // Find or create user in SwiftData
        let fetchDescriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == email
            }
        )
        
        do {
            let existingUsers = try modelContext.fetch(fetchDescriptor)
            if let existingUser = existingUsers.first {
                currentUser = existingUser
            } else {
                let newUser = User(email: email)
                modelContext.insert(newUser)
                try modelContext.save()
                currentUser = newUser
            }
            
            isAuthenticated = true
            return true
        } catch {
            print("Error managing user: \(error)")
            return false
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        isAuthenticated = false
        currentUser = nil
    }
    
    private func checkAuthenticationStatus() {
        if UserDefaults.standard.string(forKey: userDefaultsKey) != nil {
            isAuthenticated = true
        }
    }
    
    func loadCurrentUser(modelContext: ModelContext) {
        guard let email = UserDefaults.standard.string(forKey: userEmailKey) else { return }
        
        let fetchDescriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == email
            }
        )
        
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            currentUser = users.first
        } catch {
            print("Error loading current user: \(error)")
        }
    }
}