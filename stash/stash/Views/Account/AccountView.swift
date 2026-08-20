//
//  AccountView.swift
//  stash
//
//  Account tab — settings: salary & saving, currency, redo onboarding.
//

import SwiftUI
import SwiftData

struct AccountView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = AccountVM()
    @State private var showCurrencyPicker = false
    @State private var showRestartConfirm = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        StashTheme {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header
                    settingsList
                    versionFooter
                }
                .padding(.horizontal, Spacing.containerPadding)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCurrencyPicker) {
            CurrencyPickerSheet(vm: vm, selected: profile?.currency ?? .rsd)
                .presentationDetents([.height(320)])
                .presentationBackground(Color.surfaceContainerLow)
        }
        .alert("account.restart_confirm_title", isPresented: $showRestartConfirm) {
            Button("common.cancel_btn", role: .cancel) {}
            Button("account.restart_cta", role: .destructive) {
                Task { await vm.restartOnboarding(in: modelContext) }
            }
        } message: {
            Text("account.restart_confirm")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("account.title")
                .font(.screenTitleStyle)
                .foregroundColor(.appPrimary)
            Text("account.subtitle")
                .font(.secondaryStyle)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var settingsList: some View {
        VStack(spacing: Spacing.gutter) {
            NavigationLink {
                ChangeSalaryView()
            } label: {
                settingsRow(icon: "wallet.bifold", title: "account.salary_row", value: nil)
            }
            .buttonStyle(.plain)

            Button { showCurrencyPicker = true } label: {
                settingsRow(icon: "coloncurrencysign.circle", title: "account.currency_row",
                            value: currencyValue)
            }
            .buttonStyle(.plain)

            Button { vm.replayWalkthrough(in: modelContext) } label: {
                settingsRow(icon: "questionmark.circle", title: "account.walkthrough_row", value: nil)
            }
            .buttonStyle(.plain)

            Button { showRestartConfirm = true } label: {
                settingsRow(icon: "arrow.counterclockwise", title: "account.restart_row", value: nil)
            }
            .buttonStyle(.plain)
        }
    }

    private func settingsRow(icon: String, title: LocalizedStringKey, value: String?) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.white.opacity(Opacity.surface))
                    .scaledSquare(Size.iconBadge)
                Image(systemName: icon)
                    .accessibilityHidden(true)
                    .iconSize(IconSize.md)
                    .foregroundColor(.appPrimary)
            }
            Text(title)
                .font(.navTitleStyle)
                .foregroundColor(.onSurface)
            Spacer()
            if let value {
                Text(verbatim: value)
                    .font(.secondaryStyle)
                    .foregroundColor(.onSurfaceVariant)
            }
            Image(systemName: "chevron.right")
                .accessibilityHidden(true)
                .iconSize(IconSize.sm, weight: .medium)
                .foregroundColor(.onSurfaceVariant)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(Opacity.surfaceSubtle))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(Opacity.fill), lineWidth: Line.hairline)
        )
        .contentShape(Rectangle())
    }

    private var versionFooter: some View {
        Text(verbatim: "Stash \(appVersion)")
            .font(.noteStyle)
            .foregroundColor(.white.opacity(Opacity.shadow))
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.sm)
    }

    private var currencyValue: String? {
        guard let currency = profile?.currency else { return nil }
        return "\(currency.flag) \(currency.code)"
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return "v\(version ?? "1.0")"
    }
}

// MARK: - Currency picker

private struct CurrencyPickerSheet: View {
    @Bindable var vm: AccountVM
    let selected: Currency
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("account.currency_picker_title")
                .font(.sectionHeaderStyle)
                .foregroundColor(.onSurface)
                .padding(.bottom, Spacing.xs)
            ForEach(Currency.allCases, id: \.self) { currency in
                row(currency)
            }
            if vm.conversionFailed {
                Text("account.currency_error")
                    .font(.noteStyle)
                    .foregroundColor(.appError)
            }
            Spacer()
        }
        .padding(Spacing.containerPadding)
        .padding(.top, Spacing.md)
        .overlay {
            if vm.isConverting {
                ZStack {
                    Color.black.opacity(Opacity.shadow).ignoresSafeArea()
                    ProgressView().tint(.appPrimary)
                }
            }
        }
        .disabled(vm.isConverting)
    }

    private func row(_ currency: Currency) -> some View {
        Button {
            Task {
                await vm.setCurrency(currency, in: modelContext)
                if !vm.conversionFailed { dismiss() }
            }
        } label: {
            HStack(spacing: Spacing.md) {
                Text(verbatim: currency.flag).iconSize(IconSize.xl)
                Text(verbatim: currency.name)
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
                Spacer()
                if currency == selected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                        .iconSize(IconSize.smd, weight: .bold)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(Opacity.surfaceLow))
            .cornerRadius(Radius.xl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(currency == selected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
    .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
