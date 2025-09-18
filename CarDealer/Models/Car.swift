//
//  Car.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@Model
final class Car {
    @Attribute(.unique) var id: UUID
    var make: String
    var model: String
    var year: Int
    var price: Double
    var imageURL: String
    var sellerID: UUID?
    var isFromAPI: Bool
    
    @Relationship var seller: User?
    @Relationship(deleteRule: .cascade, inverse: \Order.car) var orders: [Order] = []
    @Relationship(deleteRule: .cascade, inverse: \Like.car) var likes: [Like] = []
    
    init(id: UUID = UUID(), make: String, model: String, year: Int, price: Double, imageURL: String, sellerID: UUID? = nil, isFromAPI: Bool = false) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.price = price
        self.imageURL = imageURL
        self.sellerID = sellerID
        self.isFromAPI = isFromAPI
    }
}

// MARK: - Codable Support for JSON Import
extension Car {
    struct CarJSON: Codable {
        let id: Int
        let make: String
        let model: String
        let year: Int
        let price: Double
        let image_url: String
        
        enum CodingKeys: String, CodingKey {
            case id, make, model, year, price
            case image_url
        }
    }
    
    convenience init(from carJSON: CarJSON) {
        // Convert Int ID to UUID for consistency
        let uuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-000000000000", carJSON.id)) ?? UUID()
        self.init(
            id: uuid,
            make: carJSON.make,
            model: carJSON.model,
            year: carJSON.year,
            price: carJSON.price,
            imageURL: carJSON.image_url,
            isFromAPI: true
        )
    }
}
