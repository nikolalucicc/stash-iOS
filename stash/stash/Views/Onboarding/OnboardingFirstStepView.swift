//
//  OnboardingFirstStepView.swift
//  stash
//
//  Created by Nikola on 16. 5. 2026..
//

import SwiftUI
import SwiftData

struct OnboardingFirstStepView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingFirstStepVM()

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                OnboardingAppBar()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressIndicator(currentStep: 1)
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
        vm.salaryText = profile.monthlySalary.serbianFormatted
        if vm.paydayOptions.contains(profile.paydayPeriod) {
            vm.selectedPeriod = profile.paydayPeriod
        }
    }

    private func saveProfile() {
        let profile = UserProfile.current(in: modelContext)
        profile.monthlySalary = vm.salaryText.parsedSerbianNumber
        profile.paydayPeriod = vm.selectedPeriod
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
                .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            salaryField
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
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 4)

            HStack {
                TextField("", text: bindable.salaryText)
                    .font(.inputValStyle)
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                Text("common.rsd")
                    .font(.secondaryStyle)
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.leading, Spacing.sm)
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.03))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.appPrimary.opacity(0.6), lineWidth: 0.5)
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

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.35))
            Text("onboarding.step1.privacy_note")
                .font(.noteStyle)
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.white.opacity(0.05))
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
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.accent)
                .cornerRadius(Radius.xl)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
