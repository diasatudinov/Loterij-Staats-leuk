//
//  MainTab.swift
//  Loterij Staats leuk
//

import SwiftUI

// MARK: - Tabs

enum MainTab: String, CaseIterable {
    case home = "Home"
    case groups = "Groups"
    case archive = "Archive"
    case stats = "Stats"

    var icon: String {
        switch self {
        case .home: return "house"
        case .groups: return "person.2"
        case .archive: return "archivebox"
        case .stats: return "chart.bar"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .groups: return "person.2.fill"
        case .archive: return "archivebox.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}

// MARK: - Palette

enum AppPalette {
    static let background = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let card = Color.white
    static let orange = Color(red: 1.0, green: 0.37, blue: 0.02)
    static let orangeSoft = Color(red: 1.0, green: 0.88, blue: 0.78)
    static let blue = Color(red: 0.02, green: 0.43, blue: 0.62)
    static let blueLight = Color(red: 0.07, green: 0.66, blue: 0.82)
    static let darkBlue = Color(red: 0.00, green: 0.20, blue: 0.30)
    static let navy = Color(red: 0.00, green: 0.12, blue: 0.20)
    static let textBlue = Color(red: 0.00, green: 0.35, blue: 0.55)
    static let muted = Color.gray.opacity(0.65)
    static let stroke = Color.black.opacity(0.07)
}
