//
//  User.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var avatarURL: String
    
    @Relationship(deleteRule: .cascade, inverse: \Car.seller) var carsForSale: [Car] = []
    @Relationship(deleteRule: .cascade, inverse: \Order.user) var orders: [Order] = []
    @Relationship(deleteRule: .cascade, inverse: \Like.user) var likes: [Like] = []
    
    init(email: String, displayName: String = "", avatarURL: String = "") {
        self.id = UUID()
        self.email = email
        self.displayName = displayName.isEmpty ? email.components(separatedBy: "@").first ?? "User" : displayName
        self.avatarURL = avatarURL
    }
}
