//
//  GoalCard.swift
//  stash
//
//  A single savings goal row in the wishlist.
//

import SwiftUI

struct GoalCard: View {
    let goal: SavingsGoal

    var body: some View {
        VStack(spacing: Spacing.md) {
            header
            progress
        }
        .padding(Spacing.lg)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)
                Text(verbatim: goal.emoji)
                    .font(.system(size: 24))
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
            .background(priorityColor.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(priorityColor.opacity(0.3), lineWidth: 0.5))
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
                    Capsule().fill(Color.white.opacity(0.05))
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
        return "\(saved) / \(target) \(String(localized: "common.rsd"))"
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
