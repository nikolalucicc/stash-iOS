//
//  FixedExpenseSheet.swift
//  stash
//
//  Add or edit a single fixed expense. The icon is derived from the name.
//

import SwiftUI
import SwiftData

struct FixedExpenseSheet: View {

    @Bindable var vm: FixedExpensesVM
    let currencyCode: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(vm.isEditing ? "expenses.edit_title" : "expenses.add_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            nameField
            amountField
            saveButton
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("onboarding.step3.name_label")
            TextField("onboarding.step3.name_placeholder", text: $vm.nameText)
                .font(.inputValStyle)
                .foregroundColor(.onSurface)
                .frame(minHeight: Size.field)
                .padding(.horizontal, Spacing.md)
                .background(Color.white.opacity(Opacity.surface))
                .cornerRadius(Radius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.white.opacity(Opacity.border), lineWidth: Line.hairline)
                )
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("onboarding.step3.amount_label")
            HStack {
                TextField("0", text: $vm.amountText)
                    .font(.inputValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                    .thousandsGrouped($vm.amountText)
                Text(verbatim: currencyCode)
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            .frame(minHeight: Size.field)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surface))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(Opacity.border), lineWidth: Line.hairline)
            )
        }
    }

    private func fieldLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.labelCapsStyle)
            .tracking(0.6)
            .foregroundColor(.onSurfaceVariant)
            .padding(.leading, 4)
    }

    private var saveButton: some View {
        Button {
            Task { await vm.save(to: modelContext); dismiss() }
        } label: {
            Text(vm.isEditing ? "expenses.save_cta" : "common.add_btn")
                .font(.navTitleStyle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Size.field)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!vm.canSave)
        .opacity(vm.canSave ? 1 : Opacity.muted)
    }
}

#Preview {
    FixedExpenseSheet(vm: FixedExpensesVM(), currencyCode: "RSD")
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
                  SpendingEntry.self, SpendingCategory.self],
            inMemory: true
        )
}
