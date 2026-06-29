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

    /// Live thousands grouping for number-pad input: keeps digits only, drops
    /// leading zeros, and inserts "." every three digits (e.g. "085000" → "85.000").
    var groupedThousandsInput: String {
        let digits = String(filter(\.isNumber).drop(while: { $0 == "0" }))
        guard !digits.isEmpty else { return "" }
        let count = digits.count
        var result = ""
        for (index, char) in digits.enumerated() {
            if index != 0 && (count - index) % 3 == 0 { result.append(".") }
            result.append(char)
        }
        return result
    }
}
