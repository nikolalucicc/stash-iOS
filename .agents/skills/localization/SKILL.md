---
name: localization
description: Add and use localized strings in the Stash iOS app. Use whenever introducing or changing user-facing text, adding a new screen's copy, or wiring strings in Views vs ViewModels. Covers the LocalizedStringKey vs String(localized:) vs verbatim decision and the en+sr requirement.
---

# Localization (Stash iOS)

The app uses native iOS localization with `Localizable.strings`. There is **no typed `Strings` wrapper** — call sites reference dot-namespaced keys directly. Every user-facing string must exist in both languages.

Files:
- `stash/stash/en.lproj/Localizable.strings` — **default**, real English copy.
- `stash/stash/sr.lproj/Localizable.strings` — Serbian mirror (same keys).

## Which API to use

| Context | Use | Example |
|---|---|---|
| SwiftUI `Text`, `TextField` placeholder, `Label` | `LocalizedStringKey` literal | `Text("onboarding.step1.title")` |
| ViewModel / any `String`-typed value | `String(localized:)` | `String(localized: "currency.rsd_name")` |
| Parameterized / formatted | `String(format:)` + `String(localized:)` | `String(format: String(localized: "dashboard.days_value"), days)` |
| Must NOT be looked up | `Text(verbatim:)` | `Text(verbatim: vm.formattedAmount)` |

**`Text("...")` is resolved as a key.** So `Text(expense.name)` would (wrongly) try to look up the user's text. Use `Text(verbatim: expense.name)` for:
- already-resolved VM strings (`method.label`, `currency.name`)
- formatted numbers (`amount.serbianFormatted`)
- brand names (`"Stash"`), user-entered text, currency codes.

## Adding a new key

1. Choose a dot-namespaced key: `feature.subfeature.element` (e.g. `settings.save_btn`, `dashboard.days_value`).
2. Add it under the matching `// MARK: -` section in **`en.lproj`** with the real English value.
3. Add the **same key** to **`sr.lproj`** with the Serbian translation. Never leave a key in only one file.
4. For `String(format:)` keys, add a `/* %d = ... */` comment above the entry describing each placeholder.

```strings
// en.lproj
/* %d = number of days until the next payday */
"dashboard.days_value" = "%d days";

// sr.lproj
/* %d = broj dana do sledeće plate */
"dashboard.days_value" = "%d dana";
```

## Conventions
- Keep keys grouped by feature under `// MARK: - Feature` headers, aligned `=` for readability.
- Reuse existing keys instead of duplicating identical copy (e.g. reuse `common.rsd`, `onboarding.step1.salary_label` where the label is the same).
- `common.*` for shared UI (buttons, units, validation), `<feature>.*` for screen-specific copy.
- English is the source of truth; write it as final product copy, not a placeholder.

## Checklist
- [ ] Key added to **both** en and sr
- [ ] Views use `Text("key")`; VMs use `String(localized:)`
- [ ] Dynamic/already-resolved/number strings use `Text(verbatim:)`
- [ ] Placeholders documented with a comment for `String(format:)` keys
