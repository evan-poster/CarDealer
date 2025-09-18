//
//  Like.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@Model
final class Like {
    @Attribute(.unique) var id: UUID
    var carID: UUID
    var userID: UUID
    var timestamp: Date
    
    @Relationship var car: Car?
    @Relationship var user: User?
    
    init(carID: UUID, userID: UUID) {
        self.id = UUID()
        self.carID = carID
        self.userID = userID
        self.timestamp = Date()
    }
}
