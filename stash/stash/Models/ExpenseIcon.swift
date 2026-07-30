//
//  ExpenseIcon.swift
//  stash
//
//  Picks an SF Symbol for a fixed expense from its name, so the user doesn't
//  have to choose one. Shared by onboarding and the fixed-expenses screen.
//

import Foundation

enum ExpenseIcon {

    static let fallback = "tag.fill"

    /// Best-guess icon for an expense name (case-insensitive keyword match).
    static func suggested(for name: String) -> String {
        let text = name.lowercased()
        for rule in rules where rule.keywords.contains(where: text.contains) {
            return rule.icon
        }
        return fallback
    }

    private static let rules: [(icon: String, keywords: [String])] = [
        ("house.fill", ["rent", "apartment", "lease", "housing"]),
        ("dumbbell.fill", ["gym", "fitness", "sport", "workout"]),
        ("play.rectangle.fill", ["netflix", "hbo", "streaming", "prime", "disney", "spotify"]),
        ("bolt.fill", ["electricity", "electric", "power", "utility"]),
        ("wifi", ["internet", "wifi", "broadband"]),
        ("phone.fill", ["phone", "mobile", "cellular"]),
        ("banknote", ["installment", "loan", "credit", "mortgage"]),
        ("shield.fill", ["insurance"]),
        ("car.fill", ["car", "fuel", "petrol", "parking"]),
        ("cart.fill", ["groceries", "market", "food"])
    ]
}
