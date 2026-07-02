//
//  PaydayReminderCard.swift
//  stash
//
//  Shown under the stash card when the salary has landed: prompts the user to
//  confirm they set aside this month's saving, then adds it to the stash.
//
//  NOTE: the "payday landed" trigger is currently hardcoded (shows whenever a
//  monthly saving exists and it hasn't been confirmed this session) so the flow
//  can be tested. Real payday-date tracking will replace `shouldShow`.
//

import SwiftUI
import SwiftData

struct PaydayReminderCard: View {

    let profile: UserProfile
    let currencyCode: String

    @Environment(\.modelContext) private var modelContext
    @State private var confirmed = false

    private var shouldShow: Bool { !confirmed && profile.monthlySaving > 0 }

    private var amountText: String {
        "\(profile.monthlySaving.serbianFormatted) \(currencyCode)"
    }

    private var promptText: String {
        String(format: String(localized: "payday.prompt"), amountText)
    }

    var body: some View {
        if shouldShow {
            card
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
                Text("payday.title")
                    .font(.sectionHeaderStyle)
                    .foregroundColor(.onSurface)
            }
            Text(verbatim: promptText)
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
            confirmButton
        }
        .padding(Spacing.md)
        .background(Color.appPrimary.opacity(0.08))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.appPrimary.opacity(0.25), lineWidth: 0.5)
        )
    }

    private var confirmButton: some View {
        Button { confirm() } label: {
            Text("payday.confirm_cta")
                .font(.navTitleStyle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.accent)
                .cornerRadius(Radius.lg)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func confirm() {
        profile.addMonthlySavingToStash()
        try? modelContext.save()
        withAnimation { confirmed = true }
    }
}
