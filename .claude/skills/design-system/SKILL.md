---
name: design-system
description: Reference for the Stash iOS design system — spacing, radius, color, and typography tokens, plus the StashTheme wrapper and common card/field styles. Use when building or restyling any UI so values match AppTheme instead of being hardcoded.
---

# Design system (Stash iOS)

All tokens live in `stash/stash/Theme/AppTheme.swift`. **Never hardcode** spacing, radii, colors, or font sizes — use the tokens below. Dark mode only (for now).

## Screen scaffold

Wrap screen content in `StashTheme` (dark background + radial glow) and hide the nav bar:
```swift
var body: some View {
    StashTheme {
        VStack(spacing: 0) { /* app bar, ScrollView, footer */ }
    }
    .navigationBarHidden(true)
}
```

## Spacing (`Spacing.*`, CGFloat)
`xs` 4 · `sm` 8 · `base` 8 · `gutter` 12 · `md` 16 · `lg` 24 · `xl` 32 · `containerPadding` 20

Use `containerPadding` for horizontal screen padding, `gutter` for stacks of cards, `xs`/`sm` for tight label/field spacing.

## Radius (`Radius.*`, CGFloat)
`default` 4 · `lg` 8 · `xl` 12 · `full` 9999

Cards/fields use `Radius.xl`; small inner chips/icon tiles use `Radius.lg`; large hero cards use a literal `20` (matches existing cards).

## Typography (`Font.*`)
`heroNumStyle` 48 · `displayLgStyle` 36 · `displayValStyle` 24 · `screenTitleStyle` 22 · `sectionHeaderStyle` 18 · `navTitleStyle` 16 · `inputValStyle` 15 · `bodyStyle` 14 · `secondaryStyle` 13 · `noteStyle` 12 · `labelCapsStyle` 11 (uppercase, `.tracking(0.6)`) · `labelSmStyle` 10

All are `Inter`. Use `.system(size:)` only for SF Symbol glyphs, never for text.

## Colors (`Color.*`)
Semantic tokens — prefer these over raw values:
- Surface/background: `appBackground`, `surfaceContainer`, `surfaceContainerLow`, `surfaceContainerHighest`
- Content: `onSurface` (primary text), `onSurfaceVariant` (secondary text)
- Brand: `appPrimary` (#c5c0ff, accents/icons), `accent` (#7F77DD, primary buttons & active progress), `onPrimary`, `onPrimaryContainer`
- Status: `appError` (validation/destructive), `outlineVariant` (dividers)
- Subtle fills/strokes: `Color.white.opacity(0.03–0.12)` for glass surfaces and hairline borders.

`Color(hex:)` is allowed only for one-off gradient stops not covered by a token (e.g. `Color(hex: "#534AB7")` in a button gradient).

## Common patterns

**Glass card / field**
```swift
.padding(Spacing.md)
.background(Color.white.opacity(0.03))
.cornerRadius(Radius.xl)
.overlay(RoundedRectangle(cornerRadius: Radius.xl)
    .stroke(Color.white.opacity(0.08), lineWidth: 0.5))
```

**Field label** — `labelCapsStyle`, `.tracking(0.6)`, `.foregroundColor(.white.opacity(0.4))`, `.padding(.leading, 4)`.

**Primary button** — `Text(...).font(.navTitleStyle).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.accent).cornerRadius(Radius.xl)`, wrapped in `Button { } label: { }` with `.buttonStyle(.plain)`.

**Validation state** — border switches to `Color.appError`; inline error uses `noteStyle` + `appError` with an `exclamationmark.triangle.fill` glyph.

**Selected / active** — fill `Color.accent` or `appPrimary.opacity(0.15)`, stroke `appPrimary`, text `appPrimary` / `onPrimaryContainer`.

## Adding a token
If a value is reused, add it to `AppTheme.swift` (with the existing groups) rather than repeating literals. Keep the `Spacing`/`Radius` enums and the `Color`/`Font` extensions as the single source of truth.
