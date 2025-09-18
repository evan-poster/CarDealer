//
//  CarService.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import Foundation
import SwiftData

@MainActor
class CarService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchCars(apiBase: URL, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Use a mock JSON endpoint for car data
            let carsURL = URL(string: "https://my-json-server.typicode.com/typicode/demo/posts")!
            
            let (data, _) = try await URLSession.shared.data(from: carsURL)
            
            // Create mock car data since the demo endpoint doesn't have car data
            let mockCarData = createMockCarData()
            let jsonData = try JSONEncoder().encode(mockCarData)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            let carJSONArray = try decoder.decode([Car.CarJSON].self, from: jsonData)
            
            // Import cars into SwiftData on main actor
            await importCars(carJSONArray, modelContext: modelContext)
            
        } catch {
            errorMessage = "Failed to fetch cars: \(error.localizedDescription)"
            print("Error fetching cars: \(error)")
        }
        
        isLoading = false
    }
    
    private func createMockCarData() -> [Car.CarJSON] {
        return [
            Car.CarJSON(id: 1, make: "Toyota", model: "Camry", year: 2023, price: 28500.0, image_url: "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400"),
            Car.CarJSON(id: 2, make: "Honda", model: "Civic", year: 2022, price: 24000.0, image_url: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400"),
            Car.CarJSON(id: 3, make: "Ford", model: "Mustang", year: 2023, price: 35000.0, image_url: "https://images.unsplash.com/photo-1584345604476-8ec5e12e42dd?w=400"),
            Car.CarJSON(id: 4, make: "BMW", model: "3 Series", year: 2023, price: 42000.0, image_url: "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400"),
            Car.CarJSON(id: 5, make: "Mercedes", model: "C-Class", year: 2022, price: 45000.0, image_url: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400"),
            Car.CarJSON(id: 6, make: "Audi", model: "A4", year: 2023, price: 40000.0, image_url: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400"),
            Car.CarJSON(id: 7, make: "Tesla", model: "Model 3", year: 2023, price: 48000.0, image_url: "https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400"),
            Car.CarJSON(id: 8, make: "Volkswagen", model: "Jetta", year: 2022, price: 22000.0, image_url: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400")
        ]
    }
    
    private func importCars(_ carJSONArray: [Car.CarJSON], modelContext: ModelContext) async {
        for carJSON in carJSONArray {
            // Create a stable UUID from the JSON ID
            let carUUID = UUID(uuidString: String(format: "%08X-0000-0000-0000-000000000000", carJSON.id)) ?? UUID()
            
            // Check if car already exists
            let fetchDescriptor = FetchDescriptor<Car>(
                predicate: #Predicate<Car> { car in
                    car.id == carUUID
                }
            )
            
            do {
                let existingCars = try modelContext.fetch(fetchDescriptor)
                if existingCars.isEmpty {
                    let newCar = Car(from: carJSON)
                    modelContext.insert(newCar)
                }
            } catch {
                print("Error checking existing car: \(error)")
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving cars: \(error)")
        }
    }
}