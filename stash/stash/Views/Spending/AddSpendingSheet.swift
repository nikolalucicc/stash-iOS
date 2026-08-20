//
//  AddSpendingSheet.swift
//  stash
//
//  Logs a new spend into the chosen category, or deletes the category.
//

import SwiftUI
import SwiftData

struct AddSpendingSheet: View {

    let category: SpendingCategory
    let currencyCode: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var vm = SpendingVM()
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            header
            amountField
            noteField
            saveButton
            deleteButton
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
        .alert("spending.delete_category_title", isPresented: $showDeleteConfirm) {
            Button("common.cancel_btn", role: .cancel) {}
            Button("spending.delete_category_cta", role: .destructive) {
                Task { await vm.deleteCategory(category, in: modelContext); dismiss() }
            }
        } message: {
            Text("spending.delete_category_message")
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: category.icon)
                .accessibilityHidden(true)
                .iconSize(IconSize.md)
                .foregroundColor(.appPrimary)
            Text(verbatim: category.name)
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
        .frame(minHeight: Size.field)
        .padding(.horizontal, Spacing.md)
        .background(Color.white.opacity(Opacity.surface))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(Opacity.border), lineWidth: Line.hairline)
        )
    }

    private var noteField: some View {
        let bindable = Bindable(vm)
        return TextField("spending.note_placeholder", text: bindable.note)
            .font(.bodyStyle)
            .foregroundColor(.onSurface)
            .frame(minHeight: Size.controlMd)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surfaceLow))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(Opacity.fill), lineWidth: Line.hairline)
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
                .frame(minHeight: Size.field)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!vm.canSave)
        .opacity(vm.canSave ? 1 : 0.4)
    }

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            Text("spending.delete_category_cta")
                .font(.bodyStyle)
                .foregroundColor(.appError)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Size.controlSm)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddSpendingSheet(category: SpendingCategory(name: "Food", icon: "fork.knife"), currencyCode: "RSD")
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
                  SpendingEntry.self, SpendingCategory.self],
            inMemory: true
        )
}
