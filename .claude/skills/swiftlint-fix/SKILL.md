---
name: swiftlint-fix
description: Resolve SwiftLint violations in the Stash iOS app. Use when a push/CI fails on SwiftLint, when `swiftlint --strict` reports issues, or proactively before committing Swift changes. Covers the exact rules this project trips on and how to fix each cleanly.
---

# Fixing SwiftLint violations (Stash iOS)

SwiftLint runs via a **pre-push git hook** and **GitHub Actions CI** (`swiftlint --strict` on `stash/`). A single violation rejects the push (`SwiftLint failed. Fix errors before pushing.`). Run it locally first:

```bash
cd stash && swiftlint --strict      # same as CI
swiftlint --fix                     # auto-fix the mechanical ones
```

Config lives in `stash/.swiftlint.yml`. Prefer fixing the code over loosening rules; only edit the config for genuinely conventional short names.

## Rules this project trips on — and the fix

### `function_body_length` (≤ 50 lines)
SwiftUI view builders grow fast. Split the body into smaller pieces:
- Extract sections into `private var someSection: some View { ... }`.
- Extract repeated/parameterized rows into `private func row(_ item: T) -> some View { ... }`.
- Move a card's header/stats/footer into separate computed properties.

### `type_body_length` (≤ 300 lines)
A big `struct View` with many subviews. Move **non-view helpers** (derived values, formatting, calculations) into an extension — extensions are not counted:
```swift
private extension DashboardView {
    func fixedTotal(for profile: UserProfile) -> Double { ... }
}
```

### `multiple_closures_with_trailing_closure`
Never `Button(action: {}) { }`. Use the multiple-trailing-closure form:
```swift
Button { doThing() } label: { Text("key") }
```
Same idea for any API with two closures.

### `identifier_name` (min length 3)
Rename single/2-char locals descriptively: `f → formatter`, `r/g/b → red/green/blue`, `n → lowercased`, `b → bindable`. Only the names in `.swiftlint.yml` `excluded` are allowed short (`id`, `vm`, `xs`, `sm`, `md`, `lg`, `xl`). Add a new short name to `excluded` **only** if it's a pervasive, conventional design-token abbreviation; otherwise rename.

### `implicit_optional_initialization`
Drop `= nil`: `var onBack: (() -> Void)?` not `var onBack: (() -> Void)? = nil`.

### `type_name` (UpperCamelCase types)
Capitalize type names — applies to auto-generated Xcode test classes too: `stashTests → StashTests`, `stashApp → StashApp`. `@main` works regardless of the struct's name.

### `static_over_final_class`
Use `static` over `class` for overridable type members where possible: `override static var runsForEach... ` not `override class var ...`.

### `line_length` (120)
Break long expressions — especially `||` chains in keyword matching and long `String(format:...)` lines — across multiple lines.

## Workflow
1. Reproduce with `swiftlint --strict` (not just `swiftlint`).
2. Try `swiftlint --fix` for mechanical issues, review the diff.
3. Fix remaining violations by the patterns above.
4. Re-run `swiftlint --strict` until clean, then build/test.

When you add a new screen, mentally check the three big ones (`function_body_length`, `type_body_length`, `identifier_name`) before declaring done — they're the recurring offenders here.
