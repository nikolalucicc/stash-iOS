//
//  WalkthroughView.swift
//  stash
//
//  First-run feature tour: a few paged cards explaining the main tabs.
//  Also replayable from the Account screen.
//

import SwiftUI

struct WalkthroughView: View {

    let onFinish: () -> Void

    @State private var page = 0

    private struct Step: Identifiable {
        let id = UUID()
        let icon: String
        let title: LocalizedStringKey
        let text: LocalizedStringKey
    }

    private let steps: [Step] = [
        Step(icon: "star.fill", title: "walkthrough.goals_title", text: "walkthrough.goals_text"),
        Step(icon: "calendar", title: "walkthrough.monthly_title", text: "walkthrough.monthly_text"),
        Step(icon: "tray.and.arrow.down.fill", title: "walkthrough.stash_title", text: "walkthrough.stash_text"),
        Step(icon: "person.fill", title: "walkthrough.account_title", text: "walkthrough.account_text")
    ]

    private var isLast: Bool { page == steps.count - 1 }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                skipBar
                TabView(selection: $page) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        stepPage(step).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                dots
                    .padding(.bottom, Spacing.lg)
                primaryButton
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.bottom, Spacing.xl)
            }
        }
    }

    private var skipBar: some View {
        HStack {
            Spacer()
            Button { onFinish() } label: {
                Text("walkthrough.skip")
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            .buttonStyle(.plain)
            .opacity(isLast ? 0 : 1)
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }

    private func stepPage(_ step: Step) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 132, height: 132)
                Image(systemName: step.icon)
                    .font(.system(size: 54, weight: .medium))
                    .foregroundColor(.appPrimary)
            }
            VStack(spacing: Spacing.sm) {
                Text(step.title)
                    .font(.screenTitleStyle)
                    .foregroundColor(.onSurface)
                    .multilineTextAlignment(.center)
                Text(step.text)
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.xl)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var dots: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(steps.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.accent : Color.white.opacity(0.15))
                    .frame(width: index == page ? 20 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
    }

    private var primaryButton: some View {
        Button {
            if isLast {
                onFinish()
            } else {
                withAnimation { page += 1 }
            }
        } label: {
            Text(isLast ? "walkthrough.done" : "common.continue_btn")
                .font(.navTitleStyle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WalkthroughView(onFinish: {})
}
