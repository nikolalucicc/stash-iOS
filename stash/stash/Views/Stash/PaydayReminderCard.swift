//
//  PaydayReminderCard.swift
//  stash
//
//  Shown under the stash card once the salary has landed for the month (based
//  on the chosen payday period): prompts the user to confirm they set aside
//  this month's saving, then adds it to the stash. Shows once per payday until
//  confirmed (tracked on the profile, so it survives relaunches).
//

import SwiftUI
import SwiftData

struct PaydayReminderCard: View {

    let profile: UserProfile
    let currencyCode: String

    @Environment(\.modelContext) private var modelContext

    private var shouldShow: Bool { profile.isPaydayDue() }

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
        withAnimation {
            profile.confirmMonthlySaving()
            try? modelContext.save()
        }
    }
}
