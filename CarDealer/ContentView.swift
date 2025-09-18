//
//  ContentView.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SignInView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Car.self, Order.self, Like.self])
}
