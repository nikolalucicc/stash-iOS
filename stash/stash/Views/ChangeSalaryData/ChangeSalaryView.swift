//
//  ChangeSalaryView.swift
//  stash
//
//  Salary settings screen — lets the user edit salary, payday and saving
//  preferences after onboarding. Reached from the gear icon on the dashboard.
//

import SwiftUI
import SwiftData

struct ChangeSalaryView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = ChangeSalaryVM()

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        subtitle
                        inputGroup
                        infoBox
                        projectionCard
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
                Spacer(minLength: 0)
                footer
            }
        }
        .navigationBarHidden(true)
        .task { await vm.load(from: modelContext) }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        ZStack {
            Text("settings.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.vertical, Spacing.sm)
    }

    private var subtitle: some View {
        Text("settings.subtitle")
            .font(.secondaryStyle)
            .foregroundColor(.onSurfaceVariant)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Inputs

    private var inputGroup: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            salaryField
            paydayField
            methodSelector
            savingsField
        }
    }

    private func fieldLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.labelCapsStyle)
            .tracking(0.6)
            .foregroundColor(.white.opacity(0.4))
            .padding(.leading, 4)
    }

    private var salaryField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("onboarding.step1.salary_label")
            HStack {
                TextField("", text: bindable.salaryText)
                    .font(.inputValStyle)
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .thousandsGrouped(bindable.salaryText)
                Text(verbatim: currencyCode)
                    .font(.secondaryStyle)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
        }
    }

    private var paydayField: some View {
        let bindable = Bindable(vm)
        return DropdownPicker(
            label: String(localized: "onboarding.step1.payday_label"),
            options: vm.paydayOptions,
            selection: bindable.selectedPeriod
        )
    }

    private var methodSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel("onboarding.step2.method_label")
            HStack(spacing: Spacing.sm) {
                ForEach(SavingMethod.allCases, id: \.self) { method in
                    methodButton(method)
                }
            }
        }
    }

    private func methodButton(_ method: SavingMethod) -> some View {
        let isSelected = vm.savingMethod == method
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { vm.savingMethod = method }
        } label: {
            Text(verbatim: method.label)
                .font(.secondaryStyle)
                .foregroundColor(isSelected ? .appPrimary : .onSurfaceVariant)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .fill(isSelected ? Color.appPrimary.opacity(0.15) : Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(isSelected ? Color.appPrimary : Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var savingsField: some View {
        let bindable = Bindable(vm)
        let labelKey: LocalizedStringKey = vm.savingMethod == .percentage
            ? "onboarding.step2.percentage_label"
            : "onboarding.step2.fixed_label"
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            fieldLabel(labelKey)
            HStack {
                if vm.savingMethod == .percentage {
                    TextField("", text: bindable.percentageText)
                        .font(.inputValStyle)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                } else {
                    TextField("", text: bindable.fixedAmountText)
                        .font(.inputValStyle)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .thousandsGrouped(bindable.fixedAmountText)
                }
                Spacer()
                Text(verbatim: vm.savingMethod == .percentage ? "%" : currencyCode)
                    .font(.secondaryStyle)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(
                        vm.savingExceedsSalary ? Color.appError : Color.white.opacity(0.12),
                        lineWidth: vm.savingExceedsSalary ? 1 : 0.5
                    )
            )
            if vm.savingExceedsSalary {
                validationError
            }
        }
    }

    private var validationError: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11))
            Text("common.saving_exceeds_salary")
                .font(.noteStyle)
        }
        .foregroundColor(.appError)
        .padding(.leading, 4)
    }
}

// MARK: - Info, projection & footer

private extension ChangeSalaryView {

    var infoBox: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 32, height: 32)
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.appPrimary)
            }
            Text("settings.info")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Projection Card

    private var projectionCard: some View {
        projectionContent
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
            .background(projectionBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
            .clipped()
    }

    private var projectionContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("settings.projection_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.appPrimary)
            Text("settings.projection_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
                .padding(.top, Spacing.xs)
            Spacer(minLength: Spacing.lg)
            HStack(alignment: .lastTextBaseline, spacing: Spacing.xs) {
                Text(verbatim: "+\(vm.projectedSavingFormatted)")
                    .font(.displayValStyle)
                    .foregroundColor(.onSurface)
                Text(verbatim: projectionUnit)
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
        }
    }

    private var projectionBackground: some View {
        ZStack {
            Color.white.opacity(0.03)
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.2), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack {
                Spacer()
                Image(systemName: "creditcard")
                    .font(.system(size: 120, weight: .ultraLight))
                    .foregroundColor(.appPrimary.opacity(0.1))
                    .offset(x: 24, y: 28)
            }
        }
    }

    private var projectionUnit: String {
        "\(currencyCode)\(String(localized: "settings.per_month_suffix"))"
    }

    // MARK: - Footer

    private var footer: some View {
        Button {
            Task {
                await vm.save(to: modelContext)
                dismiss()
            }
        } label: {
            Text("settings.save_btn")
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
    ChangeSalaryView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self], inMemory: true)
}
