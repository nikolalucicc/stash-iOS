//
//  AddCategorySheet.swift
//  stash
//
//  Creates a new spending category (name + icon).
//

import SwiftUI
import SwiftData

struct AddCategorySheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var vm = AddCategoryVM()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("spending.new_category_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            nameField
            duplicateNote
            iconGrid
            saveButton
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
        .onAppear { vm.loadExistingNames(from: modelContext) }
    }

    /// Says why the button is dimmed instead of letting the name look accepted.
    @ViewBuilder
    private var duplicateNote: some View {
        if vm.isDuplicate {
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
    }

    private var nameField: some View {
        let bindable = Bindable(vm)
        return TextField("spending.category_name_placeholder", text: bindable.name)
            .font(.inputValStyle)
            .foregroundColor(.onSurface)
            .frame(height: Size.field)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surface))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(vm.isDuplicate ? Color.appError : Color.white.opacity(Opacity.border),
                            lineWidth: Line.hairline)
            )
    }

    private var iconGrid: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(SpendingCategory.iconChoices, id: \.self) { choice in
                iconCell(choice)
            }
        }
    }

    private func iconCell(_ choice: String) -> some View {
        let isSelected = vm.icon == choice
        return Button { vm.icon = choice } label: {
            // Not hidden: the symbol's own name is the only thing that tells
            // these fourteen cells apart out loud.
            Image(systemName: choice)
                .font(.system(size: IconSize.lg))
                .foregroundColor(isSelected ? .white : .appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Size.controlMd)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(isSelected ? Color.accent : Color.white.opacity(Opacity.surface))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var saveButton: some View {
        Button {
            Task { await vm.save(in: modelContext); dismiss() }
        } label: {
            Text("spending.add_category_cta")
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
}

#Preview {
    AddCategorySheet()
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
                  SpendingEntry.self, SpendingCategory.self],
            inMemory: true
        )
}
