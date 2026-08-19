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
                .foregroundColor(.white.opacity(Opacity.muted))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: AppDuration.standard)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(selection)
                            .font(.inputValStyle)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .accessibilityHidden(true)
                            .foregroundColor(.white.opacity(Opacity.muted))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: AppDuration.standard), value: isExpanded)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(Opacity.fill))
                        .padding(.horizontal, Spacing.md)

                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                withAnimation(.easeInOut(duration: AppDuration.standard)) {
                                    selection = option
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(.inputValStyle)
                                        .foregroundColor(option == selection ? .accent : .white.opacity(0.7))
                                    Spacer()
                                    if option == selection {
                                        Image(systemName: "checkmark")
                                            .accessibilityHidden(true)
                                            .font(.system(size: IconSize.sm, weight: .medium))
                                            .foregroundColor(.accent)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm + 2)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(option == selection ? [.isSelected] : [])

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
            .background(Color.white.opacity(Opacity.surfaceSubtle))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(
                        isExpanded
                            ? Color.appPrimary.opacity(Opacity.muted)
                            : Color.white.opacity(Opacity.borderStrong),
                        lineWidth: Line.hairline
                    )
                    .animation(.easeInOut(duration: AppDuration.standard), value: isExpanded)
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
