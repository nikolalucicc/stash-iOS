---
name: swiftui-screen
description: Conventions for building screens and view models in the Stash iOS app. Use whenever creating or editing a SwiftUI View, a ViewModel, a SwiftData model, or wiring navigation/persistence — to match the project's architecture, theming, localization, concurrency and SwiftLint rules.
---

# Building screens & view models (Stash iOS)

Follow these conventions for any new screen, component, or view model. They reflect the latest Swift / SwiftUI standards (iOS 17+) and the existing codebase. **Match the surrounding code** — if an existing file does something differently, prefer the local pattern.

## Architecture: MVVM with `@Observable`

- One view model per screen: `@Observable @MainActor final class XxxVM`. Use `@Observable` (not `ObservableObject`/`@Published`).
- The view owns the VM with `@State private var vm = XxxVM()`.
- **Views are dumb.** No business logic, formatting rules, or persistence in the view body — push it into the VM as computed properties or methods.
- **Derived state = computed properties** on the VM (e.g. `monthlySaving`, `projectedSavingFormatted`). Don't store what you can compute.
- **Side effects = methods.** In this project VM side-effecting methods are `async` (e.g. `func load(from: ModelContext) async`, `func save(to: ModelContext) async`) — keep new ones `async` too, even if the body is currently synchronous, so call sites stay future-proof.
- Inject dependencies (like `ModelContext`) as method parameters; don't capture global singletons.
- **Changing VM logic? Update its tests in the same change and re-run them** — see the `xctest-screen` skill. A logic edit that leaves tests untouched is incomplete.

```swift
@Observable
@MainActor
final class ExampleVM {
    var amountText: String = ""

    var amount: Double { amountText.parsedSerbianNumber }      // derived
    var isValid: Bool { amount > 0 }                            // validation

    func load(from context: ModelContext) async { /* ... */ }  // async side effect
    func save(to context: ModelContext) async {
        guard isValid else { return }                          // guard invalid writes
        try? context.save()
    }
}
```

## View structure & SwiftLint limits

SwiftLint (`.swiftlint.yml`) is enforced by a **pre-push hook and CI** — a violation blocks the push. **CI runs `swiftlint --strict`** (warnings become errors); the local pre-push hook is **not** strict, so it can pass while CI fails. Always run `swiftlint --strict` yourself from the `stash/` directory. Design for it up front:

- Strict thresholds (errors under `--strict`): **`function_body_length` ≤ 50**, **`type_body_length` ≤ 250**, **`file_length` ≤ 400** (excluding comments/whitespace). Keep `body` tiny; split UI into small `private var section: some View` computed properties and `private func row(_:) -> some View` helpers.
- When a `struct` View nears the 250-line type limit, move pure helpers (derived values, formatting) **and whole view sections** into a `private extension XxxView { }` — extensions don't count toward `type_body_length`. When the **file** nears 400 lines, move supporting types / small subviews into their own file (e.g. `XxxComponents.swift`).
- **`identifier_name` min length 3.** Use descriptive names (`bindable`, `formatter`, not `b`, `f`). Allowed short names are only those in `.swiftlint.yml` `excluded` (`id`, `vm`, `xs`, `sm`, `md`, `lg`, `xl`).
- **Buttons use multiple-trailing-closure syntax:** `Button { action } label: { content }` — never `Button(action:){ }`. Add `.buttonStyle(.plain)` for custom-styled buttons.
- Don't initialize optionals with `= nil` (`implicit_optional_initialization`): write `var onBack: (() -> Void)?`.

## Theming — never hardcode

Wrap screen content in `StashTheme { ... }` (dark background + glow) and `.navigationBarHidden(true)`.

Use design tokens from `Theme/AppTheme.swift` exclusively:
- Spacing: `Spacing.xs/sm/gutter/md/lg/xl/containerPadding` — no raw paddings like `.padding(16)`.
- Radius: `Radius.lg/xl/full` for `cornerRadius` / `RoundedRectangle`.
- Colors: semantic tokens (`.onSurface`, `.onSurfaceVariant`, `.appPrimary`, `.accent`, `.appError`, `Color.white.opacity(...)`). Only use `Color(hex:)` for one-off gradient stops that aren't tokens.
- Fonts: the named styles (`.screenTitleStyle`, `.bodyStyle`, `.labelCapsStyle`, `.displayValStyle`, ...). Don't invent `.system(size:)` except for SF Symbol glyphs.

## Localization (en + sr)

Every user-facing string is localized. There is no typed `Strings` wrapper — call sites use keys directly.

- In **Views**, pass the key as a `LocalizedStringKey` literal: `Text("onboarding.step1.title")`, `TextField("placeholder.key", text:)`. SwiftUI resolves it at render.
- In **VMs / non-View `String` contexts**, use `String(localized: "some.key")`. For parameterized strings: `String(format: String(localized: "key.with_%d"), value)`.
- Use `Text(verbatim:)` for strings that must NOT be looked up: already-resolved VM strings, brand names (`"Stash"`), formatted numbers, user-entered text.
- **Add every new key to BOTH** `en.lproj/Localizable.strings` (default, real English copy) and `sr.lproj/Localizable.strings` (Serbian). Keep dot-namespaced keys (`feature.subfeature.element`) grouped under a `// MARK:` section.

## Persistence (SwiftData)

- Models are `@Model final class` in `Models/`. Store enums as raw `String` columns plus a typed computed accessor (see `UserProfile.savingMethod`). Relationships use `@Relationship(deleteRule:inverse:)`.
- `@main` app sets `.modelContainer(for: [...])` once; this propagates `@Environment(\.modelContext)` everywhere, including sheets/`fullScreenCover`.
- Read in views with `@Query`; the UI auto-refreshes on save.
- Follow the single-record lookup pattern: `UserProfile.current(in:)` (fetch-or-create) and `.existing(in:)` (read-only). Persist edits by mutating the model then `try? context.save()`.

## State, bindings & concurrency

- Bindings into a child: `@Bindable var vm: XxxVM` (param) or `let bindable = Bindable(vm)` then `bindable.field` inside a computed view property.
- Load on appear with `.task { await vm.load(from: modelContext) }`; run button side effects in `Task { await vm.save(...); dismiss() }`.
- Navigation: `NavigationStack` + `NavigationLink`/`navigationDestination`. Present settings/modals with `.sheet` or `.fullScreenCover`. Gate forward navigation with `.disabled(!vm.canContinue)` + `.opacity(vm.canContinue ? 1 : 0.4)`.

## Validation

Expose validity as VM computed properties (`isValid` / `canSave` / `canContinue` + a specific flag like `savingExceedsSalary`). In the view: tint the field border `.appError`, show an inline `.noteStyle` error row, disable+dim the primary action, and `guard` the write inside the VM method.

## File layout

`Views/<Feature>/<Feature>View.swift`, with view models in `ViewModels/` (or alongside in the feature folder). Reusable UI goes in `Views/Components/`. SwiftData models in `Models/`. The Xcode project uses file-system-synchronized groups, so new files are picked up automatically — no `.pbxproj` editing.

## Checklist before finishing

- [ ] `body` small; sections split into computed props / small funcs (≤ 50 lines each)
- [ ] Type body ≤ 250 lines (helpers/sections moved to a `private extension`); file ≤ 400 lines
- [ ] Only design tokens (Spacing/Radius/colors/fonts) — no magic numbers
- [ ] All strings localized in **both** `en` and `sr`
- [ ] VM is `@Observable @MainActor final class`; side effects `async`; derived state computed
- [ ] Buttons use `Button { } label: { }`; identifiers ≥ 3 chars
- [ ] Mentally run `swiftlint --strict` — no `function_body_length` / `type_body_length` / `identifier_name` violations
