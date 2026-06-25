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
        .confirmationDialog("account.restart_confirm", isPresented: $showRestartConfirm,
                            titleVisibility: .visible) {
            Button("account.restart_cta") {
                Task { await vm.restartOnboarding(in: modelContext) }
            }
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
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
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
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.onSurfaceVariant)
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.03))
        .cornerRadius(Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
    }

    private var versionFooter: some View {
        Text(verbatim: "Stash \(appVersion)")
            .font(.noteStyle)
            .foregroundColor(.white.opacity(0.3))
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
                    Color.black.opacity(0.3).ignoresSafeArea()
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
                Text(verbatim: currency.flag).font(.system(size: 22))
                Text(verbatim: currency.name)
                    .font(.navTitleStyle)
                    .foregroundColor(.onSurface)
                Spacer()
                if currency == selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.04))
            .cornerRadius(Radius.xl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
    .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self], inMemory: true)
}
