//
//  OnboardingSecondStepView.swift
//  stash
//
//  Created by Nikola on 17. 5. 2026..
//

import SwiftUI

struct OnboardingSecondStepView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm = OnboardingSecondStepVM()

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
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step2.title")
                .font(.screenTitleStyle)
                .foregroundColor(.onSurface)
            Text("onboarding.step2.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: Spacing.xl) {
            methodSelector
            savingsInput
            if vm.savingMethod == .percentage {
                previewCard
            }
        }
    }

    // MARK: - Method Selector

    private var methodSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("onboarding.step2.method_label")
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 4)

            HStack(spacing: Spacing.gutter) {
                ForEach(SavingMethod.allCases, id: \.self) { method in
                    let isSelected = vm.savingMethod == method
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.savingMethod = method
                        }
                    }) {
                        Text(verbatim: method.label)
                            .font(.navTitleStyle)
                            .foregroundColor(isSelected ? .onPrimaryContainer : .onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm + 4)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.lg)
                                    .fill(isSelected ? Color.accent : Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.lg)
                                    .stroke(
                                        isSelected ? Color.clear : Color.white.opacity(0.1),
                                        lineWidth: 0.5
                                    )
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Savings Input

    private var savingsInput: some View {
        let b = Bindable(vm)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(verbatim: vm.savingMethod.inputLabel)
                .font(.labelCapsStyle)
                .tracking(0.6)
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 4)

            HStack {
                if vm.savingMethod == .percentage {
                    TextField("", text: b.percentageText)
                        .font(.inputValStyle)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                } else {
                    TextField("", text: b.fixedAmountText)
                        .font(.inputValStyle)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }
                Spacer()
                Text(verbatim: vm.savingMethod.inputUnit)
                    .font(.inputValStyle)
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.03))
            .cornerRadius(Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .stroke(Color.appPrimary.opacity(0.5), lineWidth: 1)
            )
        }
    }

    // MARK: - Preview Card

    private var previewCard: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Color.appPrimary.opacity(0.1))
                .frame(width: 128, height: 128)
                .blur(radius: 24)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("onboarding.step2.preview_label")
                    .font(.labelSmStyle)
                    .foregroundColor(.onSurfaceVariant)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(verbatim: vm.monthlySavingFormatted)
                        .font(.displayValStyle)
                        .foregroundColor(Color(hex: "#AFA9EC"))
                    Text("common.rsd")
                        .font(.inputValStyle)
                        .foregroundColor(.white.opacity(0.35))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.lg)
        .background(Color.appPrimary.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appPrimary.opacity(0.2), lineWidth: 0.5)
        )
        .clipped()
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink(destination: OnboardingThirdStepView()) {
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

            HStack(spacing: Spacing.md) {
                Rectangle()
                    .fill(Color.outlineVariant.opacity(0.5))
                    .frame(height: 0.5)
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 13))
                        Text("common.back_btn")
                            .font(.secondaryStyle)
                    }
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

#Preview {
    NavigationStack {
        OnboardingSecondStepView()
    }
}
