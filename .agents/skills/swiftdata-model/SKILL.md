---
name: swiftdata-model
description: Create and work with SwiftData @Model classes in the Stash iOS app. Use when adding a persisted model, a relationship, querying data in a view, or wiring the model container. Covers the project's enum-as-raw-String pattern, single-record lookup helpers, and in-memory containers for previews/tests.
---

# SwiftData models (Stash iOS)

Local persistence uses **SwiftData** (iOS 17+). Models live in `stash/stash/Models/`. The app is on-device only — nothing is sent to a server.

## Defining a model

```swift
import Foundation
import SwiftData

@Model
final class UserProfile {
    var monthlySalary: Double
    var savingMethodRaw: String          // enum stored as raw String
    var onboardingCompleted: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \FixedExpenseEntity.profile)
    var expenses: [FixedExpenseEntity] = []

    init(monthlySalary: Double = 85_000, onboardingCompleted: Bool = false) {
        self.monthlySalary = monthlySalary
        self.savingMethodRaw = SavingMethod.percentage.rawValue
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = .now
    }
}
```

### Enums as raw String + typed accessor
SwiftData stores primitives well; persist enums via their `String` raw value and expose a typed computed accessor (keeps call sites type-safe, storage migratable):
```swift
enum SavingMethod: String, CaseIterable { case percentage, fixed }

extension UserProfile {
    var savingMethod: SavingMethod {
        get { SavingMethod(rawValue: savingMethodRaw) ?? .percentage }
        set { savingMethodRaw = newValue.rawValue }
    }
}
```

### Relationships
Use `@Relationship(deleteRule: .cascade, inverse:)` on the parent; the child holds an optional back-reference (`var profile: UserProfile?`). When replacing a child collection, snapshot the old array before deleting to avoid mutating it mid-iteration.

## Single-record lookup pattern

For one-per-device records, provide static helpers instead of scattering `FetchDescriptor`s:
```swift
extension UserProfile {
    static func current(in context: ModelContext) -> UserProfile {     // fetch-or-create
        if let existing = try? context.fetch(FetchDescriptor<UserProfile>()).first { return existing }
        let profile = UserProfile(); context.insert(profile); return profile
    }
    static func existing(in context: ModelContext) -> UserProfile? {   // read-only
        try? context.fetch(FetchDescriptor<UserProfile>()).first
    }
}
```
Use `existing(in:)` for read-only pre-fills (don't create a record prematurely); `current(in:)` when about to write.

## Wiring & usage

- The `@main` app registers the container once:
  ```swift
  WindowGroup { RootView() }
      .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self])
  ```
  This propagates `@Environment(\.modelContext)` to every view, including `.sheet` / `.fullScreenCover`.
- Read in a view with `@Query private var profiles: [UserProfile]` — the UI auto-refreshes on save.
- Write from a VM method: mutate the model, then `try? context.save()`. Guard invalid writes (e.g. `guard canSave else { return }`).
- Add new model types to the `modelContainer(for:)` array **and** any `#Preview` / test container.

## Previews & tests

Use an in-memory container so previews/tests don't touch the on-device store:
```swift
#Preview {
    DashboardView()
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self], inMemory: true)
}
```

In unit tests, **retain the `ModelContainer` for the test's lifetime** (a property, set in `setUp`). A `ModelContext` does not keep its container's store alive, so a helper that returns only `container.mainContext` and lets the container deallocate makes the next `fetch` trap. See the `xctest-screen` skill.

## Checklist
- [ ] `@Model final class` in `Models/`
- [ ] Enums persisted as raw `String` + typed accessor
- [ ] Relationships use `deleteRule` + `inverse`, child has optional back-ref
- [ ] New type added to `modelContainer(for:)` and preview/test containers
- [ ] Reads via `@Query`; writes mutate model then `try? context.save()`
