//
//  EnvironmentKeys.swift
//  CarDealer
//
//  Created by Evan Poster on 9/17/25.
//

import SwiftUI

// MARK: - API Base Environment Key
struct APIBaseKey: EnvironmentKey {
    static let defaultValue: URL = URL(string: "https://jsonplaceholder.typicode.com")!
}

extension EnvironmentValues {
    var apiBase: URL {
        get { self[APIBaseKey.self] }
        set { self[APIBaseKey.self] = newValue }
    }
}

// MARK: - Theme Tokens Environment Key
struct ThemeTokens {
    let cornerRadius: CGFloat
    let spacing: CGFloat
    let cardPadding: CGFloat
    let shadowRadius: CGFloat
    
    static let `default` = ThemeTokens(
        cornerRadius: 12,
        spacing: 16,
        cardPadding: 16,
        shadowRadius: 4
    )
}

struct ThemeTokensKey: EnvironmentKey {
    static let defaultValue = ThemeTokens.default
}

extension EnvironmentValues {
    var themeTokens: ThemeTokens {
        get { self[ThemeTokensKey.self] }
        set { self[ThemeTokensKey.self] = newValue }
    }
}