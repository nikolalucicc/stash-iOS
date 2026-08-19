# Fix catalog: Swift 6 concurrency warnings (Stash iOS)

Read the warning, find its shape below, apply the smallest fix that *states real isolation* rather than escaping the checker. Each entry gives the diagnostic you'll see, why the compiler complains, and the fix for this codebase.

## Table of contents

1. [`@Observable` view model missing `@MainActor`](#1-observable-view-model-missing-mainactor)
2. [Non-Sendable type crossing a task boundary](#2-non-sendable-type-crossing-a-task-boundary)
3. [SwiftData `ModelContext` / `@Model` and actor isolation](#3-swiftdata-modelcontext--model-and-actor-isolation)
4. [`ExchangeRateService` and the network layer](#4-exchangerateservice-and-the-network-layer)
5. [Capture of non-Sendable in a `Task` / closure](#5-capture-of-non-sendable-in-a-task--closure)
6. [Global / static mutable state](#6-global--static-mutable-state)
7. [Calling a `@MainActor` API from a `nonisolated` context](#7-calling-a-mainactor-api-from-a-nonisolated-context)
8. [Escape hatches — when they're actually correct](#8-escape-hatches--when-theyre-actually-correct)

---

## 1. `@Observable` view model missing `@MainActor`

**Diagnostic:** `main actor-isolated property 'x' can not be referenced from a non-isolated context`, or a warning that the type isn't `Sendable` when SwiftUI touches it.

**Why:** SwiftUI reads and mutates view-model state on the main thread. If the class isn't isolated to the main actor, the compiler can't prove those accesses are race-free.

**Fix:** annotate the class with `@MainActor` (alongside `@Observable`). This is already the project convention — see [swiftui-screen](../../swiftui-screen/SKILL.md). Most Stash VMs have it; check the onboarding VMs, which may not.

```swift
@Observable
@MainActor                       // add this
final class OnboardingFirstStepVM {
    var name: String = ""
    // ...
}
```

Once the type is `@MainActor`, all its stored properties and methods inherit that isolation — you rarely need per-member annotations. `@MainActor` types are usable from other `@MainActor` code without `await`; callers that are *not* main-actor-isolated will need `await`, which points you at the next thing to migrate up the call graph.

---

## 2. Non-Sendable type crossing a task boundary

**Diagnostic:** `type 'Foo' does not conform to the 'Sendable' protocol` / `non-sendable type 'Foo' ... cannot cross actor boundary`.

**Why:** `Sendable` marks values that are safe to hand from one concurrency domain to another. Value types (structs/enums) whose members are all Sendable get it for free; reference types (classes) don't, because they share mutable state.

**Decision order:**

1. **Is it a struct or enum with Sendable members?** It's *already* `Sendable` implicitly — don't annotate it. The Stash enums (`Currency`, `SavingMethod`, `PayPeriod`) and the plain structs qualify.
2. **Is it a public/framework value type the compiler can't infer across module lines?** Add explicit `: Sendable`.
3. **Is it a class you own that's genuinely immutable** (only `let` properties of Sendable types)? Make it `final` and add `: Sendable`.
4. **Is it a `@Model` class?** See [section 3](#3-swiftdata-modelcontext--model-and-actor-isolation) — do **not** slap `Sendable` on it.
5. **Is it mutable shared state that must move between domains?** Isolate it to an actor, or confine it to one actor and pass only Sendable snapshots out.

```swift
// A value carried into an async result — make the intent explicit if the compiler asks.
struct RateResult: Sendable {
    let value: Double
    let currency: Currency
}
```

---

## 3. SwiftData `ModelContext` / `@Model` and actor isolation

**Diagnostic:** `capture of 'context' with non-sendable type 'ModelContext'` or `non-sendable type 'UserProfile' ... cannot cross actor boundary`.

**Why:** `ModelContext` and `@Model` instances are **not** `Sendable` by design — a managed object is bound to the context and thread that created it. SwiftData's safety model is "one context per actor," not "share the object."

**The rule for Stash:** all persistence today runs on the main actor (VMs are `@MainActor`, `@Query` and `@Environment(\.modelContext)` are main-actor). Keep it that way and these warnings disappear on their own once the VMs are `@MainActor`. Concretely:

- Keep passing `ModelContext` as a **method parameter to `@MainActor` methods** (the existing `func save(to context: ModelContext) async` pattern). Both sides are main-actor, so nothing crosses a boundary.
- **Never** capture a `ModelContext` or a model instance in `Task.detached`, in a `@Sendable` closure that runs off the main actor, or pass one into `ExchangeRateService`-style `nonisolated` code.
- When a VM method needs a background thing (e.g. a network rate) *and* to write, fetch the Sendable value off-actor first, then hop back to the main actor to touch the context:

```swift
func refreshRate(in context: ModelContext) async {
    let rate = try? await ExchangeRateService.rate(from: .rsd, to: .eur) // off-actor, returns Double (Sendable)
    // back on the main actor here (method is @MainActor); safe to touch context
    guard let rate else { return }
    UserProfile.current(in: context).someRateField = rate
    try? context.save()
}
```

**Only if the user explicitly wants background persistence** (e.g. a large import that shouldn't block the UI) introduce a `@ModelActor`. It owns its own `ModelContext` and is the *only* correct way to touch SwiftData off the main actor:

```swift
@ModelActor
actor ImportActor {
    func importEntries(_ payloads: [EntryPayload]) throws {   // payloads must be Sendable
        for payload in payloads { modelContext.insert(SpendingEntry(from: payload)) }
        try modelContext.save()
    }
}
// create with ImportActor(modelContainer: container); pass the *container* (Sendable), never a context.
```

Don't reach for this preemptively — it's more moving parts than the main-actor path and only pays off when there's real background work.

---

## 4. `ExchangeRateService` and the network layer

**Diagnostic:** usually none — but you may see a `Sendable` complaint on its parameters or decoded payload.

**Why:** `ExchangeRateService` is a `nonisolated` async `enum` calling `URLSession.shared.data`. `URLSession` is already `Sendable`, and `async`/`await` handles the thread hop. The only requirement is that what goes in and comes out is `Sendable`.

**Fix:** ensure inputs/outputs are Sendable — `Currency` (String enum) and `Double` already are; the private `RatesPayload: Decodable` is a struct of Sendable members, so it's fine. **Do not** add `@MainActor` to this service — that would force every network call onto the main thread and defeat the point. Leave it `nonisolated`. If you extract a shared response cache or client object, *that* stateful piece is what needs isolating (an `actor`), not the request function.

---

## 5. Capture of non-Sendable in a `Task` / closure

**Diagnostic:** `capture of 'self'/'x' with non-sendable type ... in a `@Sendable` closure`.

**Why:** a `Task {}` or escaping closure may run on a different executor; the compiler checks everything captured is safe to carry there.

**Fixes, in order of preference:**

- If the closure only touches main-actor state (the common case in views: `Task { await vm.save(...); dismiss() }`), make sure the surrounding context is main-actor. In a SwiftUI `View`, `Task {}` inherits `@MainActor`, so capturing a `@MainActor` VM is fine — the warning usually means the VM isn't `@MainActor` yet ([section 1](#1-observable-view-model-missing-mainactor)).
- Capture a **Sendable snapshot** instead of the whole object: `let amount = vm.amount` before the `Task`, use `amount` inside.
- Only use `Task.detached` when you deliberately want to leave the actor — and then you must *not* capture non-Sendable state (see [section 3](#3-swiftdata-modelcontext--model-and-actor-isolation)).

---

## 6. Global / static mutable state

**Diagnostic:** `var 'shared' is not concurrency-safe because it is nonisolated global shared mutable state`.

**Why:** a mutable `static var` / global `var` is reachable from every thread with no synchronization — the classic data race.

**Fixes, in order of preference:**

1. **Make it a `let`** if it never actually mutates (most "singletons" of stateless helpers). A `let` of a Sendable type is fine.
2. **Isolate it:** `@MainActor static var` if it's UI-adjacent, or move it into an `actor`.
3. **`nonisolated(unsafe)`** *only* for something you can prove is safe (e.g. set once before any concurrency, immutable thereafter) — with a comment saying why. See [section 8](#8-escape-hatches--when-theyre-actually-correct).

Stash's `ExchangeRateService` and `enum`-namespaced helpers hold no stored state, so they don't trip this. Watch for any `static var` added later.

---

## 7. Calling a `@MainActor` API from a `nonisolated` context

**Diagnostic:** `call to main actor-isolated ... in a synchronous nonisolated context`.

**Why:** you're trying to touch main-actor state from code that isn't on the main actor (e.g. a `nonisolated` helper, a `Task.detached`, or a non-isolated protocol conformance).

**Fixes:**

- `await` it from an `async` context so the hop to the main actor is explicit: `await someMainActorThing()`.
- If the call site *should* be main-actor, annotate it `@MainActor` and let isolation flow up.
- For a synchronous callback you don't control (delegate, completion handler), wrap the main-actor work: `Task { @MainActor in ... }`.

---

## 8. Escape hatches — when they're actually correct

These silence the checker instead of satisfying it, so each needs a written justification. Use them rarely.

- **`@unchecked Sendable`** — "I guarantee thread-safety the compiler can't see." Legitimate only when you enforce it yourself (e.g. a class guarding all access with a lock/queue). **Never** on a `@Model` class or on mutable UI state.
- **`nonisolated(unsafe)`** — for a stored property (often a global) that is safe despite the compiler's doubt, e.g. assigned once during launch before any task runs. Comment the invariant.
- **`@preconcurrency import Foo`** — for a dependency not yet audited for Sendable; downgrades its Sendable errors to warnings so you can migrate your own code first. Fine as a *temporary* bridge, not a permanent state.

**Litmus test:** if you can't write one sentence explaining why the access is race-free, you don't have a fix — you have a hidden data race. Prefer stating the real actor.

---

## Quick reference: warning → section

| Warning contains… | Go to |
|---|---|
| `main actor-isolated ... non-isolated context` | [1](#1-observable-view-model-missing-mainactor), [7](#7-calling-a-mainactor-api-from-a-nonisolated-context) |
| `does not conform to 'Sendable'` | [2](#2-non-sendable-type-crossing-a-task-boundary) |
| `ModelContext` / a `@Model` name + `non-sendable` | [3](#3-swiftdata-modelcontext--model-and-actor-isolation) |
| `capture of ... in a @Sendable closure` | [5](#5-capture-of-non-sendable-in-a-task--closure) |
| `nonisolated global shared mutable state` | [6](#6-global--static-mutable-state) |
