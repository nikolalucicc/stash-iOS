//
//  GoalCard.swift
//  stash
//
//  A single savings goal row in the wishlist.
//

import SwiftUI

struct GoalCard: View {
    let goal: SavingsGoal
    var currencyCode: String = Currency.rsd.code
    /// This goal's share of the monthly budget.
    var monthlyAmount: Double = 0

    var body: some View {
        VStack(spacing: Spacing.md) {
            header
            progress
            monthlyRow
        }
        .padding(Spacing.lg)
        .background(Color.white.opacity(Opacity.surfaceSubtle))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(Opacity.fill), lineWidth: Line.hairline)
        )
    }

    /// Monthly share, plus a warning when it won't hit the deadline in time.
    @ViewBuilder
    private var monthlyRow: some View {
        if goal.remaining > 0 {
            HStack(spacing: Spacing.xs) {
                Text("goals.per_month_label")
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
                Text(verbatim: "\(monthlyAmount.serbianFormatted) \(currencyCode)")
                    .font(.noteStyle)
                    .foregroundColor(.appPrimary)
                Spacer()
                if underfunded {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: IconSize.xs))
                        Text("goals.deadline_at_risk")
                            .font(.noteStyle)
                    }
                    .foregroundColor(.appError)
                }
            }
        }
    }

    /// A deadline goal getting less than it needs won't make it in time.
    private var underfunded: Bool {
        goal.deadline != nil && monthlyAmount < goal.monthlyNeed()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.white.opacity(Opacity.surface))
                    .frame(width: 48, height: 48)
                Text(verbatim: goal.emoji)
                    .font(.system(size: IconSize.xxl))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: goal.name)
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: deadlineText)
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
            priorityBadge
        }
    }

    private var priorityBadge: some View {
        Text(verbatim: goal.priority.label.uppercased())
            .font(.labelSmStyle)
            .foregroundColor(priorityColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 4)
            .background(priorityColor.opacity(Opacity.tintFill))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(priorityColor.opacity(Opacity.shadow), lineWidth: Line.hairline))
    }

    private var progress: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text(verbatim: amountsText)
                    .font(.labelCapsStyle)
                    .foregroundColor(.onSurface)
                Spacer()
                Text(verbatim: "\(Int((goal.progress * 100).rounded()))%")
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(Opacity.surface))
                    Capsule()
                        .fill(Color.appPrimary)
                        .frame(width: proxy.size.width * goal.progress)
                }
            }
            .frame(height: 6)
        }
    }

    private var amountsText: String {
        let saved = goal.savedAmount.serbianFormatted
        let target = goal.targetAmount.serbianFormatted
        return "\(saved) / \(target) \(currencyCode)"
    }

    private var deadlineText: String {
        guard let deadline = goal.deadline else {
            return String(localized: "goals.no_deadline")
        }
        let formatted = deadline.formatted(.dateTime.month(.wide).year())
        return String(format: String(localized: "goals.until_date"), formatted)
    }

    private var priorityColor: Color {
        switch goal.priority {
        case .high:   return .appError
        case .medium: return .appPrimary
        case .low:    return .onSurfaceVariant
        }
    }
}
