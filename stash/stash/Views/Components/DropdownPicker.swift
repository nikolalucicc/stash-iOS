//
//  DropdownPicker.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import SwiftUI

struct DropdownPicker: View {

    let label: String
    let options: [String]
    @Binding var selection: String
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selection)
                            .font(.inputValStyle)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.4))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, Spacing.md)

                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = option
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.inputValStyle)
                                        .foregroundColor(option == selection ? .accent : .white.opacity(0.7))
                                    Spacer()
                                    if option == selection {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.accent)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm + 2)
                            }
                            .buttonStyle(.plain)

                            if option != options.last {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(
                        isExpanded ? Color.appPrimary.opacity(0.4) : Color.white.opacity(0.12),
                        lineWidth: 0.5
                    )
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            )
        }
    }
}

#Preview {
    @Previewable @State var selection = "Beginning of month"
    let options = ["Beginning of month", "Mid month", "End of month"]

    ZStack {
        Color.appBackground.ignoresSafeArea()
        DropdownPicker(label: "Pay period", options: options, selection: $selection)
            .padding()
    }
    .preferredColorScheme(.dark)
}
