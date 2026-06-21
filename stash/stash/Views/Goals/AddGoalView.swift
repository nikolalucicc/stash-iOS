//
//  AddGoalView.swift
//  stash
//
//  Form for creating a new wishlist goal.
//

import SwiftUI
import SwiftData

struct AddGoalView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var vm: AddGoalVM

    init(nextSortOrder: Int) {
        _vm = State(initialValue: AddGoalVM(sortOrder: nextSortOrder))
    }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        nameField
                        amountField
                        prioritySelector
                        deadlineField
                        contributionSlider
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
                footer
            }
        }
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        ZStack {
            Text("goals.add_title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.vertical, Spacing.md)
    }

    private func fieldLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.labelCapsStyle)
            .tracking(0.6)
            .foregroundColor(.onSurfaceVariant)
            .padding(.leading, 4)
    }

    private var nameField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("goals.name_label")
            TextField("goals.name_placeholder", text: bindable.name)
                .font(.inputValStyle)
                .foregroundColor(.onSurface)
                .frame(height: 56)
                .padding(.horizontal, Spacing.md)
                .background(Color.white.opacity(0.04))
                .cornerRadius(Radius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
        }
    }

    private var amountField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("goals.amount_label")
            HStack {
                TextField("0", text: bindable.amountText)
                    .font(.inputValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                Text("common.rsd")
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            .frame(height: 56)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
        }
    }

    private var prioritySelector: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("goals.priority_label")
            HStack(spacing: Spacing.sm) {
                ForEach(GoalPriority.allCases, id: \.self) { option in
                    priorityButton(option)
                }
            }
        }
    }

    private func priorityButton(_ option: GoalPriority) -> some View {
        let isSelected = vm.priority == option
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { vm.priority = option }
        } label: {
            Text(verbatim: option.label)
                .font(.secondaryStyle)
                .foregroundColor(isSelected ? .onSecondaryContainer : .onSurfaceVariant)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(isSelected ? Color.secondaryContainer : Color.white.opacity(0.05))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var deadlineField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Toggle(isOn: bindable.hasDeadline) {
                Text("goals.deadline_label")
                    .font(.labelCapsStyle)
                    .tracking(0.6)
                    .foregroundColor(.onSurfaceVariant)
            }
            .tint(.accent)
            if vm.hasDeadline {
                DatePicker("", selection: bindable.deadline, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.appPrimary)
            }
        }
        .padding(.horizontal, 4)
    }

    private var contributionSlider: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                fieldLabel("goals.contribution_label")
                Spacer()
                Text(verbatim: "\(vm.desiredMonthly.serbianFormatted) \(String(localized: "common.rsd"))")
                    .font(.sectionHeaderStyle)
                    .foregroundColor(.appPrimary)
            }
            Slider(value: bindable.desiredMonthly, in: 500...50_000, step: 500)
                .tint(.accent)
        }
    }

    private var footer: some View {
        Button {
            Task {
                await vm.save(to: modelContext)
                dismiss()
            }
        } label: {
            Text("goals.add_cta")
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
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    AddGoalView(nextSortOrder: 0)
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
