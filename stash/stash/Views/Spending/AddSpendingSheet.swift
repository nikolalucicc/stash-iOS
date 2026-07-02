//
//  AddSpendingSheet.swift
//  stash
//
//  Logs a new spend into the chosen category.
//

import SwiftUI
import SwiftData

struct AddSpendingSheet: View {

    let category: SpendingCategory
    let currencyCode: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var vm = SpendingVM()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            header
            amountField
            noteField
            saveButton
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(.appPrimary)
            Text(verbatim: category.label)
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
        }
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

    private var noteField: some View {
        let bindable = Bindable(vm)
        return TextField("spending.note_placeholder", text: bindable.note)
            .font(.bodyStyle)
            .foregroundColor(.onSurface)
            .frame(height: 48)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }

    private var saveButton: some View {
        Button {
            Task { await vm.save(category, in: modelContext); dismiss() }
        } label: {
            Text("spending.save_cta")
                .font(.navTitleStyle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!vm.canSave)
        .opacity(vm.canSave ? 1 : 0.4)
    }
}

#Preview {
    AddSpendingSheet(category: .food, currencyCode: "RSD")
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self, SpendingEntry.self],
            inMemory: true
        )
}
