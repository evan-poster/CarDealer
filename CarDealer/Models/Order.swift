//
//  Order.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@Model
final class Order {
    @Attribute(.unique) var id: UUID
    var carID: UUID
    var userID: UUID
    var timestamp: Date
    var price: Double
    
    @Relationship var car: Car?
    @Relationship var user: User?
    
    init(carID: UUID, userID: UUID, price: Double) {
        self.id = UUID()
        self.carID = carID
        self.userID = userID
        self.timestamp = Date()
        self.price = price
    }
}
