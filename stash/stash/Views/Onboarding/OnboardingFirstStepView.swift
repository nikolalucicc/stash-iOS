//
//  OnboardingFirstStepView.swift
//  stash
//
//  Created by Nikola on 16. 5. 2026..
//

import SwiftUI
import SwiftData

struct OnboardingFirstStepView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = OnboardingFirstStepVM()

    private var currencyCode: String { (profiles.first?.currency ?? .rsd).code }

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                OnboardingAppBar(onBack: { dismiss() })
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressIndicator(currentStep: 2)
                            .padding(.bottom, Spacing.xl)
                        headerSection
                            .padding(.bottom, Spacing.xl)
                        formSection
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                }
                Spacer(minLength: 40)
                footerSection
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadSavedProfile() }
    }

    // MARK: - Persistence

    private func loadSavedProfile() {
        guard let profile = UserProfile.existing(in: modelContext) else { return }
        if profile.monthlySalary > 0 {
            vm.salaryText = profile.monthlySalary.serbianFormatted
        }
        vm.selectedPeriod = profile.payPeriod.label
    }

    private func saveProfile() {
        let profile = UserProfile.current(in: modelContext)
        profile.monthlySalary = vm.salaryText.parsedSerbianNumber
        profile.payPeriod = PayPeriod.from(label: vm.selectedPeriod)
        try? modelContext.save()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step1.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
            Text("onboarding.step1.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.white.opacity(Opacity.muted))
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            salaryField
            salaryRequiredNote
            paydayField
            privacyNote
        }
    }

    private var salaryField: some View {
        let bindable = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step1.salary_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(Opacity.muted))
                .padding(.leading, 4)

            HStack {
                TextField("", text: bindable.salaryText)
                    .font(.inputValStyle)
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .thousandsGrouped(bindable.salaryText)
                Text(verbatim: currencyCode)
                    .font(.secondaryStyle)
                    .foregroundColor(.white.opacity(Opacity.mutedStrong))
                    .padding(.leading, Spacing.sm)
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(Opacity.surfaceSubtle))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.appPrimary.opacity(Opacity.strong), lineWidth: Line.hairline)
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

    /// Says why Continue is dimmed instead of leaving the user guessing.
    @ViewBuilder
    private var salaryRequiredNote: some View {
        if !vm.canContinue {
            Text("onboarding.step1.salary_required")
                .font(.noteStyle)
                .foregroundColor(.onSurfaceVariant)
                .padding(.leading, 4)
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .accessibilityHidden(true)
                .iconSize(IconSize.lg)
                .foregroundColor(.white.opacity(Opacity.mutedStrong))
            Text("onboarding.step1.privacy_note")
                .font(.noteStyle)
                .foregroundColor(.white.opacity(Opacity.mutedStrong))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.white.opacity(Opacity.surface))
        .cornerRadius(Radius.xl)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink(destination: OnboardingSecondStepView()) {
                HStack(spacing: Spacing.sm) {
                    Text("common.continue_btn")
                        .font(.navTitleStyle)
                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)
                        .iconSize(IconSize.md, weight: .medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!vm.canContinue)
            .opacity(vm.canContinue ? 1 : Opacity.muted)
            .simultaneousGesture(TapGesture().onEnded { saveProfile() })
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    NavigationStack {
        OnboardingFirstStepView()
    }
}
