//
//  ThousandsGrouping.swift
//  stash
//
//  Live thousands grouping for number-pad amount fields: as the user types,
//  leading zeros are dropped and "." is inserted every three digits.
//

import SwiftUI

private struct ThousandsGroupingModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content.onChange(of: text) { _, value in
            let formatted = value.groupedThousandsInput
            if formatted != value { text = formatted }
        }
    }
}

extension View {
    /// Applies live thousands grouping to a number-pad field bound to `text`.
    func thousandsGrouped(_ text: Binding<String>) -> some View {
        modifier(ThousandsGroupingModifier(text: text))
    }
}
