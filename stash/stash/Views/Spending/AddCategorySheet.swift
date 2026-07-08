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
            iconGrid
            saveButton
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
    }

    private var nameField: some View {
        let bindable = Bindable(vm)
        return TextField("spending.category_name_placeholder", text: bindable.name)
            .font(.inputValStyle)
            .foregroundColor(.onSurface)
            .frame(height: 56)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(0.05))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
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
            Image(systemName: choice)
                .font(.system(size: 18))
                .foregroundColor(isSelected ? .white : .appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(isSelected ? Color.accent : Color.white.opacity(0.05))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            Task { await vm.save(in: modelContext); dismiss() }
        } label: {
            Text("spending.add_category_cta")
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
    AddCategorySheet()
        .modelContainer(
            for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
                  SpendingEntry.self, SpendingCategory.self],
            inMemory: true
        )
}
