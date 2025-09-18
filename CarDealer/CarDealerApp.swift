//
//  CarDealerApp.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI
import SwiftData

@main
struct CarDealerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Car.self,
            Order.self,
            Like.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environment(\.apiBase, URL(string: "https://jsonplaceholder.typicode.com")!)
                .environment(\.themeTokens, ThemeTokens.default)
        }
    }
}
