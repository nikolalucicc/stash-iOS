//
//  OnboardingFourthStepView.swift
//  stash
//
//  Created by Nikola on 24. 5. 2026..
//

import SwiftUI
import SwiftData

struct OnboardingFourthStepView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingFourthStepVM()

    var body: some View {
        StashTheme {
            VStack(spacing: 0) {
                OnboardingAppBar()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressIndicator(currentStep: 1)
                            .padding(.bottom, Spacing.xs)
                        headerSection
                            .padding(.bottom, Spacing.xl)
                        currencyList
                    }
                    .padding(.horizontal, Spacing.containerPadding)
                    .padding(.top, Spacing.lg)
                }
                Spacer(minLength: 32)
                footerSection
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadSavedProfile() }
    }

    // MARK: - Persistence

    private func loadSavedProfile() {
        guard let profile = UserProfile.existing(in: modelContext) else { return }
        vm.selectedCurrency = profile.currency
    }

    private func saveCurrency() {
        let profile = UserProfile.current(in: modelContext)
        profile.currency = vm.selectedCurrency
        try? modelContext.save()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step4.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
            Text("onboarding.step4.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    // MARK: - Currency List

    private var currencyList: some View {
        VStack(spacing: Spacing.gutter) {
            ForEach(Currency.allCases, id: \.self) { currency in
                currencyCard(currency)
            }
        }
    }

    private func currencyCard(_ currency: Currency) -> some View {
        let isSelected = vm.selectedCurrency == currency
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                vm.selectedCurrency = currency
            }
        } label: {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(Color.surfaceContainer)
                        .frame(width: 40, height: 40)
                    Text(verbatim: currency.flag)
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: currency.name)
                        .font(.navTitleStyle)
                        .foregroundColor(.onSurface)
                    Text(verbatim: currency.code)
                        .font(.noteStyle)
                        .foregroundColor(.onSurfaceVariant)
                }
                Spacer()
                selectionIndicator(isSelected: isSelected)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(isSelected ? Color.accent.opacity(0.15) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(
                        isSelected ? Color.accent : Color.white.opacity(0.08),
                        lineWidth: 0.5
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.onPrimary)
            } else {
                Circle()
                    .stroke(Color.outlineVariant, lineWidth: 0.5)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 24, height: 24)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink(destination: OnboardingFirstStepView()) {
                HStack(spacing: Spacing.sm) {
                    Text("common.continue_btn")
                        .font(.navTitleStyle)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#534AB7"), Color(hex: "#7F77DD")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(Radius.xl)
                .shadow(color: Color(hex: "#534AB7").opacity(0.3), radius: 15, x: 0, y: 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { saveCurrency() })
        }
        .padding(.horizontal, Spacing.containerPadding)
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    NavigationStack {
        OnboardingFourthStepView()
    }
}
