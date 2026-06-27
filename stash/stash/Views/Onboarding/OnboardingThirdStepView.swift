//
//  OnboardingThirdStepView.swift
//  stash
//
//  Created by Nikola on 24. 5. 2026..
//

import SwiftUI
import SwiftData

struct OnboardingThirdStepView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = OnboardingThirdStepVM()

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                OnboardingAppBar(onBack: { dismiss() })
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressIndicator(currentStep: 4, suffix: String(localized: "onboarding.step3.progress_suffix"))
                            .padding(.bottom, Spacing.xl)
                        headerSection
                            .padding(.bottom, Spacing.xl)
                        expenseSection
                        if !vm.expenses.isEmpty {
                            summaryRow
                        }
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
                Spacer(minLength: 32)
                footerSection
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: Binding(
            get: { vm.showAddSheet },
            set: { vm.showAddSheet = $0 }
        )) {
            AddExpenseSheetView(vm: vm, currencyCode: currencyCode)
                .presentationDetents([.height(480)])
                .presentationBackground(Color.surfaceContainerLow)
                .presentationDragIndicator(.visible)
        }
        .onAppear { loadSavedExpenses() }
    }

    // MARK: - Persistence

    private func loadSavedExpenses() {
        guard vm.expenses.isEmpty, let profile = UserProfile.existing(in: modelContext) else { return }
        vm.expenses = profile.expenses
            .sorted { $0.createdAt < $1.createdAt }
            .map { FixedExpense(name: $0.name, note: $0.note, amount: $0.amount, icon: $0.icon) }
    }

    private func saveExpenses() {
        let profile = UserProfile.current(in: modelContext)
        let previouslySaved = profile.expenses
        for expense in previouslySaved {
            modelContext.delete(expense)
        }
        profile.expenses = vm.expenses.map {
            FixedExpenseEntity(name: $0.name, note: $0.note, amount: $0.amount, icon: $0.icon)
        }
        try? modelContext.save()
    }

    private func finishOnboarding() {
        let profile = UserProfile.current(in: modelContext)
        profile.onboardingCompleted = true
        try? modelContext.save()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("onboarding.step3.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
            Text("onboarding.step3.subtitle")
                .font(.bodyStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    // MARK: - Expense Section

    private var expenseSection: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(vm.expenses) { expense in
                expenseRow(expense)
            }
            addButton
        }
        .padding(.bottom, Spacing.gutter)
    }

    private func expenseRow(_ expense: FixedExpense) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 36, height: 36)
                Image(systemName: expense.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: expense.name)
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: expense.note)
                    .font(.noteStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(verbatim: expense.amount.serbianFormatted)
                    .font(.displayValStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: currencyCode)
                    .font(.labelSmStyle)
                    .foregroundColor(.onSurface)
            }
            Button { vm.delete(expense) } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.appError)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var addButton: some View {
        Button { vm.showAddSheet = true } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurfaceVariant)
                Text("onboarding.step3.add_expense_btn")
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white.opacity(0.05))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                    .foregroundColor(.outlineVariant)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack {
            Text("onboarding.step3.total_label")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(verbatim: vm.totalFormatted)
                    .font(.displayLgStyle)
                    .foregroundColor(.appPrimary)
                Text(verbatim: currencyCode)
                    .font(.bodyStyle)
                    .foregroundColor(.onSurface)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.lg)
        .overlay(
            Rectangle()
                .fill(Color.outlineVariant)
                .frame(height: 0.5),
            alignment: .top
        )
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: Spacing.md) {
            Button {
                saveExpenses()
                finishOnboarding()
            } label: {
                Text("onboarding.step4.finish_btn")
                    .font(.navTitleStyle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.accent)
                    .cornerRadius(Radius.xl)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: Spacing.md) {
                Rectangle()
                    .fill(Color.outlineVariant.opacity(0.5))
                    .frame(height: 0.5)
                Button {
                    saveExpenses()
                    finishOnboarding()
                } label: {
                    Text("common.skip_btn")
                        .font(.secondaryStyle)
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
                Rectangle()
                    .fill(Color.outlineVariant.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheetView: View {

    @Bindable var vm: OnboardingThirdStepVM
    var currencyCode: String = Currency.rsd.code

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("onboarding.step3.sheet_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.lg)

            VStack(spacing: Spacing.md) {
                nameField
                amountField
            }
            .padding(.horizontal, Spacing.containerPadding)

            Spacer()

            VStack(spacing: Spacing.sm) {
                Button { vm.addExpense() } label: {
                    Text("common.add_btn")
                        .font(.navTitleStyle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.accent)
                        .cornerRadius(Radius.xl)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button { vm.cancelAdd() } label: {
                    Text("common.cancel_btn")
                        .font(.bodyStyle)
                        .foregroundColor(.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.containerPadding)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step3.name_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
                .padding(.leading, 4)
            TextField("onboarding.step3.name_placeholder", text: $vm.newName)
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
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step3.amount_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.onSurfaceVariant)
                .padding(.leading, 4)
            HStack {
                TextField("0", text: $vm.newAmountText)
                    .font(.inputValStyle)
                    .foregroundColor(.onSurface)
                    .keyboardType(.numberPad)
                Spacer()
                Text(verbatim: currencyCode)
                    .font(.bodyStyle)
                    .foregroundColor(.onSurfaceVariant)
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
    }
}

#Preview {
    NavigationStack {
        OnboardingThirdStepView()
    }
}
