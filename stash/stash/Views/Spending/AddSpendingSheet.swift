//
//  AddSpendingSheet.swift
//  stash
//
//  Logs a new spend into the chosen category, renames it, or deletes it.
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
            if vm.isRenaming {
                renameField
            } else {
                amountField
                noteField
                saveButton
            }
            renameButton
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
                .font(.system(size: IconSize.md))
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
        .frame(height: Size.field)
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
            .frame(height: Size.controlMd)
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
                .frame(height: Size.field)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!vm.canSave)
        .opacity(vm.canSave ? 1 : Opacity.muted)
    }

    /// Renaming carries the category's spends with it — they are matched by
    /// name, so the old name would strand every one of them.
    private var renameField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            TextField("spending.category_name_placeholder", text: bindable.renameText)
                .font(.inputValStyle)
                .foregroundColor(.onSurface)
                .frame(height: Size.field)
                .padding(.horizontal, Spacing.md)
                .background(Color.white.opacity(Opacity.surface))
                .cornerRadius(Radius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(isDuplicate ? Color.appError : Color.white.opacity(Opacity.border),
                                lineWidth: Line.hairline)
                )
            if isDuplicate {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .accessibilityHidden(true)
                        .font(.system(size: IconSize.xs))
                    Text("spending.duplicate_category")
                        .font(.noteStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(.appError)
                .padding(.leading, 4)
            }
            Button {
                Task { await vm.rename(category, in: modelContext); vm.isRenaming = false }
            } label: {
                Text("spending.rename_save_cta")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.field)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canRename)
            .opacity(canRename ? 1 : Opacity.muted)
        }
    }

    private var isDuplicate: Bool { vm.renameIsDuplicate(category, in: modelContext) }
    private var canRename: Bool { vm.canRename(category, in: modelContext) }

    private var renameButton: some View {
        Button {
            if vm.isRenaming {
                vm.isRenaming = false
            } else {
                vm.renameText = category.name
                vm.isRenaming = true
            }
        } label: {
            Text(vm.isRenaming ? "common.cancel_btn" : "spending.rename_category_cta")
                .font(.bodyStyle)
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Size.controlSm)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            Text("spending.delete_category_cta")
                .font(.bodyStyle)
                .foregroundColor(.appError)
                .frame(maxWidth: .infinity)
                .frame(height: Size.controlSm)
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
