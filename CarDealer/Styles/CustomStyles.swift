//
//  CustomStyles.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI

// MARK: - Card Style ViewModifier
struct CardStyle: ViewModifier {
    @Environment(\.themeTokens) var themeTokens
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(themeTokens.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: themeTokens.cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                        radius: themeTokens.shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Pill Button Style
struct PillButtonStyle: ButtonStyle {
    @Environment(\.themeTokens) var themeTokens
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, themeTokens.spacing)
            .padding(.vertical, themeTokens.spacing / 2)
            .background(
                Capsule()
                    .fill(Color.accentColor)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


// MARK: - Custom Shapes
struct PriceBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 8
        let notchSize: CGFloat = 6
        
        // Start from top-left
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        
        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        
        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        
        // Bottom edge with notch
        path.addLine(to: CGPoint(x: notchSize * 2, y: rect.height))
        path.addLine(to: CGPoint(x: notchSize, y: rect.height - notchSize))
        path.addLine(to: CGPoint(x: 0, y: rect.height - notchSize * 2))
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top-left corner
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        return path
    }
}