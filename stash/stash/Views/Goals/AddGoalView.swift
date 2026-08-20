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
    @Query private var profiles: [UserProfile]
    @State private var vm: AddGoalVM

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }
    private var stashBalance: Double { profiles.first?.stashBalance ?? 0 }
    private var canAffordNow: Bool {
        !vm.isEditing && vm.targetAmount > 0 && stashBalance >= vm.targetAmount
    }

    init(nextSortOrder: Int) {
        _vm = State(initialValue: AddGoalVM(sortOrder: nextSortOrder))
    }

    init(editing goal: SavingsGoal) {
        _vm = State(initialValue: AddGoalVM(editing: goal))
    }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        nameField
                        amountField
                        if canAffordNow {
                            affordableBanner
                        }
                        prioritySelector
                        deadlineField
                        monthlySection
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
            Text(vm.isEditing ? "goals.edit_title" : "goals.add_title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .accessibilityHidden(true)
                        .font(.system(size: IconSize.md, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("a11y.close"))
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
                .frame(height: Size.field)
                .padding(.horizontal, Spacing.md)
                .background(Color.white.opacity(Opacity.surfaceLow))
                .cornerRadius(Radius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.white.opacity(Opacity.borderStrong), lineWidth: Line.hairline)
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
                    .thousandsGrouped(bindable.amountText)
                Text(verbatim: currencyCode)
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            .frame(height: Size.field)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surfaceLow))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(Opacity.borderStrong), lineWidth: Line.hairline)
            )
        }
    }

    private var affordableMessage: String {
        let remaining = "\(max(0, stashBalance - vm.targetAmount).serbianFormatted) \(currencyCode)"
        return String(format: String(localized: "goals.affordable_remaining"), remaining)
    }

    private var affordableBanner: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .accessibilityHidden(true)
                    .font(.system(size: 15))
                    .foregroundColor(.appPrimary)
                Text("goals.affordable_title")
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurface)
            }
            Text(verbatim: affordableMessage)
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Task {
                    await vm.buyNow(in: modelContext)
                    dismiss()
                }
            } label: {
                Text("goals.buy_now_cta")
                    .font(.secondaryStyle)
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Size.controlSm)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .fill(Color.appPrimary.opacity(Opacity.borderStrong))
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(Color.appPrimary.opacity(Opacity.tintSubtle))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.appPrimary.opacity(Opacity.tintBorder), lineWidth: Line.hairline)
        )
    }

    /// Deadlines start next month, so there's always at least one month to save.
    private var earliestDeadline: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
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
            withAnimation(.easeInOut(duration: AppDuration.standard)) { vm.priority = option }
        } label: {
            Text(verbatim: option.label)
                .font(.secondaryStyle)
                .foregroundColor(isSelected ? .onSecondaryContainer : .onSurfaceVariant)
                .frame(maxWidth: .infinity)
                .frame(height: Size.controlSm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(isSelected ? Color.secondaryContainer : Color.white.opacity(Opacity.surface))
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
                // Next month onwards — a deadline of today would demand the
                // whole amount at once.
                DatePicker("", selection: bindable.deadline, in: earliestDeadline...,
                           displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.appPrimary)
            }
        }
        .padding(.horizontal, 4)
    }

    /// With a deadline the pace is computed; without one the user sets it.
    @ViewBuilder
    private var monthlySection: some View {
        if vm.hasDeadline {
            deadlineNeedNote
        } else {
            customMonthlyField
        }
    }

    /// Optional pace for a goal with no deadline — blank means "whatever's spare".
    private var customMonthlyField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("goals.contribution_label")
            HStack {
                TextField("0", text: bindable.monthlyText)
                    .font(.inputValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                    .thousandsGrouped(bindable.monthlyText)
                Text(verbatim: currencyCode)
                    .font(.labelCapsStyle)
                    .foregroundColor(.appPrimary)
            }
            .frame(height: Size.field)
            .padding(.horizontal, Spacing.md)
            .background(Color.white.opacity(Opacity.surfaceLow))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(Opacity.borderStrong), lineWidth: Line.hairline)
            )
            Text("goals.contribution_note")
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
        }
    }

    @ViewBuilder
    private var deadlineNeedNote: some View {
        if vm.deadlineMonthly > 0 {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .lastTextBaseline) {
                    Text(verbatim: "\(vm.deadlineMonthly.serbianFormatted) \(currencyCode)")
                        .font(.inputValStyle)
                        .foregroundColor(.appPrimary)
                    Spacer()
                    Text(verbatim: String(format: String(localized: "goals.months_count"),
                                          vm.monthsUntilDeadline))
                        .font(.noteStyle)
                        .foregroundColor(.onSurfaceVariant)
                }
                .frame(height: Size.field)
                .padding(.horizontal, Spacing.md)
                .background(Color.appPrimary.opacity(Opacity.tintSubtle))
                .cornerRadius(Radius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.appPrimary.opacity(Opacity.tintBorder), lineWidth: Line.hairline)
                )
                Text("goals.deadline_need_note")
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 4)
            }
        }
    }

    private var footer: some View {
        Button {
            Task {
                await vm.save(to: modelContext)
                dismiss()
            }
        } label: {
            Text(vm.isEditing ? "goals.save_cta" : "goals.add_cta")
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
