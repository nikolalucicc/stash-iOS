//
//  Extensions.swift
//  stash
//
//  Shared utility extensions used across the app.
//

import Foundation

// MARK: - NumberFormatter

extension NumberFormatter {
    /// Serbian-locale decimal formatter: groups thousands with ".", no decimals.
    static let serbian: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

// MARK: - Double

extension Double {
    /// Formats the value as a Serbian-locale number string (e.g. 20000 → "20.000").
    var serbianFormatted: String {
        NumberFormatter.serbian.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: - String

extension String {
    /// Parses a Serbian-formatted number string to Double (e.g. "20.000" → 20000).
    var parsedSerbianNumber: Double {
        Double(replacingOccurrences(of: ".", with: "")) ?? 0
    }
}
