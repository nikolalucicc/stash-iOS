---
name: swift6-migration
description: Migrate the Stash iOS app from Swift 5 to Swift 6 (strict concurrency / data-race safety), one file or type at a time. Use whenever the user wants to adopt Swift 6, fix Sendable / actor-isolation / data-race warnings, flip the Swift language mode, resolve "capture of non-Sendable" or "main actor-isolated" errors, or harden a file for concurrency — even if they don't say "Swift 6" by name.
---

# Swift 5 → Swift 6 migration (Stash iOS)

Swift 6's headline change is **compile-time data-race safety**: the compiler proves that no two concurrent tasks touch the same mutable state. Everything else in this skill is downstream of that one idea. Most "Swift 6 errors" are really the compiler asking you to say *which actor owns this state* and *which values are safe to cross task boundaries* (`Sendable`).

The Stash app is already well-positioned: view models are `@Observable @MainActor final class`, SwiftData work is confined to the main actor, and the only network code (`ExchangeRateService`) is a stateless `enum`. So this migration is mostly **turning on the compiler's data-race warnings and then quieting them one file at a time** — not a rewrite.

Work with the other skills, don't duplicate them: [swiftui-screen](../swiftui-screen/SKILL.md) for VM/view conventions, [swiftdata-model](../swiftdata-model/SKILL.md) for `@Model` patterns, [swiftlint-fix](../swiftlint-fix/SKILL.md) before committing, and [commit-and-pr](../commit-and-pr/SKILL.md) to land the change.

## Strategy: warnings first, language mode last

Do **not** flip `SWIFT_VERSION = 6.0` first and then drown in errors. Use Apple's recommended phased path, which keeps the project building in Swift 5 mode the whole time while surfacing Swift 6 problems as *warnings* you can burn down incrementally:

1. **Turn on strict-concurrency checking as warnings.** In `stash.xcodeproj`, set the build setting `SWIFT_STRICT_CONCURRENCY = complete` (raise it through `minimal → targeted → complete` if `complete` produces an overwhelming wall at once). Language mode stays at Swift 5, so nothing breaks the build — you just get a warning list that mirrors what Swift 6 would reject.
2. **Fix the warnings file by file** (the loop below). The project stays green after every file, so you can commit as you go.
3. **Flip the language mode.** Once `SWIFT_STRICT_CONCURRENCY = complete` builds with **zero** concurrency warnings, set `SWIFT_VERSION = 6.0`. If step 2 was thorough this is nearly a no-op; treat any new error as a missed warning and fix it the same way.

`SWIFT_VERSION` and `SWIFT_STRICT_CONCURRENCY` live per build configuration in `stash/stash.xcodeproj/project.pbxproj` (there are several `SWIFT_VERSION = 5.0;` lines — one per configuration). Prefer editing them in Xcode's Build Settings UI when the user has the project open; edit the `.pbxproj` directly only if asked, and change every configuration consistently.

## The per-file loop

For each file (start with leaves — models, services, value types — then work up to VMs and views, because callers inherit their callees' isolation):

1. **Build and read the warnings for that file.** Get the concurrency diagnostics from a real build, not from guessing:

   ```bash
   xcodebuild -project stash/stash.xcodeproj -scheme stash \
     -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 \
     | grep -E 'warning:|error:' | grep -iE 'sendable|actor|concurren|data race|isolat'
   ```

   (Adjust the simulator name to one that exists — `xcrun simctl list devices available`.)

2. **Diagnose what the compiler is actually asking.** Each warning maps to one of a handful of fixes — see the catalog in [references/patterns.md](references/patterns.md). Read it before your first fix; it has the exact Stash-specific recipes (SwiftData `ModelContext`, `ExchangeRateService`, `@Observable` VMs, global state).

3. **Apply the smallest correct fix.** Prefer *stating real isolation* over silencing. `@unchecked Sendable`, `nonisolated(unsafe)`, and `@preconcurrency` are escape hatches — reach for them only when you can articulate *why* the access is actually safe, and leave a one-line comment saying so. An unexplained escape hatch is a data race waiting to happen once someone refactors around it.

4. **Rebuild; confirm the file's warnings are gone and no new ones appeared elsewhere.** Fixes propagate — adding `@MainActor` to a type can push isolation requirements onto its callers. That's expected; follow them up the call graph.

5. **Keep tests green.** Concurrency annotations change call sites; VM test methods may need `await` / `@MainActor`. Re-run the target's tests (see [xctest-screen](../xctest-screen/SKILL.md)) — a VM logic file and its `*VMTests.swift` move together.

Commit per file or per small cluster while the project still builds, so a bad fix is easy to bisect.

## What to expect in this codebase

Ranked by how often you'll hit it here:

- **Isolation is mostly done, so let it flow.** VMs are already `@MainActor`; SwiftData `ModelContext` is only ever touched from those VMs. Most fixes are confirming an `@Observable` type carries `@MainActor` and letting that isolation cover its members — not adding locks.
- **`@Observable` VM missing `@MainActor`.** Some onboarding VMs may be `@Observable` without `@MainActor`. Add it — it matches the [swiftui-screen](../swiftui-screen/SKILL.md) convention and resolves "main actor-isolated property" churn in one stroke.
- **`ExchangeRateService`.** A `nonisolated` async `enum` calling `URLSession.shared.data`. Its inputs/outputs (`Currency`, `Double`, the private `Decodable` payload) must be `Sendable` — String-backed enums and value types already are, so this usually just works. Don't `@MainActor`-isolate the network call.
- **SwiftData across actors.** `@Model` classes and `ModelContext` are **not** `Sendable`. As long as reads/writes stay on the main actor (as they do today), you're fine. Only if the user wants *background* persistence do you need a `@ModelActor` — see [references/patterns.md](references/patterns.md). Never pass a `ModelContext` or a model instance into a `Task.detached` or across an actor hop.
- **Value types are free.** The enums (`Currency`, `SavingMethod`, `PayPeriod`) and structs are implicitly `Sendable`. Don't annotate them unless the compiler asks.

## Guardrails

- **Never** weaken correctness to silence a warning: don't sprinkle `@unchecked Sendable` on `@Model` classes, don't wrap main-actor UI state in a lock, don't `Task.detached` just to dodge isolation. If a warning is hard, the honest fix is usually to state the right actor, not to escape the checker.
- Keep the diffs small and reviewable; this is a behavior-preserving migration. If a fix changes observable behavior (e.g. moving work off the main actor), call it out to the user rather than doing it silently.
- Respect the existing conventions and SwiftLint — run `swiftlint --strict` from `stash/` before committing ([swiftlint-fix](../swiftlint-fix/SKILL.md)).

## Checklist before finishing a file

- [ ] The file builds with `SWIFT_STRICT_CONCURRENCY = complete` and **zero** concurrency warnings
- [ ] Isolation is *stated*, not escaped — every `@unchecked` / `nonisolated(unsafe)` / `@preconcurrency` has a comment justifying why it's safe
- [ ] No `ModelContext` or `@Model` instance crosses an actor boundary or enters a detached task
- [ ] `@Observable` VMs are `@MainActor`; value types left un-annotated unless required
- [ ] Tests for the file updated (`await`/`@MainActor` as needed) and passing
- [ ] `swiftlint --strict` clean
