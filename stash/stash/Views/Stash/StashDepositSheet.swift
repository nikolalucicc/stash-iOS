//
//  StashDepositSheet.swift
//  stash
//
//  Add to (or set) the general savings balance.
//

import SwiftUI
import SwiftData

struct StashDepositSheet: View {

    let currentBalance: Double
    let currencyCode: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var vm = StashVM()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            header
            amountField
            buttons
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("stash.add_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            Text(verbatim: currentBalanceText)
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var currentBalanceText: String {
        let label = String(localized: "stash.current_label")
        return "\(label): \(currentBalance.serbianFormatted) \(currencyCode)"
    }

    private var amountField: some View {
        let bindable = Bindable(vm)
        return HStack {
            TextField("0", text: bindable.amountText)
                .font(.inputValStyle)
                .foregroundColor(.onSurface)
                .keyboardType(.numberPad)
                .thousandsGrouped(bindable.amountText)
            Text(verbatim: currencyCode)
                .font(.labelCapsStyle)
                .foregroundColor(.appPrimary)
        }
        .frame(height: 56)
        .padding(.horizontal, Spacing.md)
        .background(Color.white.opacity(0.05))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }

    private var buttons: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                Task { await vm.add(in: modelContext); dismiss() }
            } label: {
                Text("stash.add_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(vm.amount <= 0)
            .opacity(vm.amount > 0 ? 1 : 0.4)

            Button {
                Task { await vm.setBalance(in: modelContext); dismiss() }
            } label: {
                Text("stash.set_cta")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    StashDepositSheet(currentBalance: 120_000, currencyCode: "RSD")
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
