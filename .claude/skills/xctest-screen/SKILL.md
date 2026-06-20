---
name: xctest-screen
description: Write unit and UI tests for the Stash iOS app — view model logic, calculations, validation, and SwiftData with an in-memory container. Use when adding test coverage for a VM, model, or screen. Targets the README goal of 70%+ coverage on the logic/data layer.
---

# Testing (Stash iOS)

Targets: `stashTests` (unit, XCTest) and `stashUITests` (UI). Test the **logic and data layer first** (highest value, README goal: 70%+ there).

Run the whole suite:
```bash
xcodebuild test -project stash/stash.xcodeproj -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Test class names are UpperCamelCase (`StashTests`) — SwiftLint `type_name` applies to test files too.

## Run each test right after you write it

**After adding or editing a test, run that specific test before moving on** — don't batch them up. Scope the run with `-only-testing:` so it's fast (a whole class or a single method):

```bash
# one test class (file)
xcodebuild test -project stash/stash.xcodeproj -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:stashTests/ChangeSalaryVMTests

# one test method
xcodebuild test -project stash/stash.xcodeproj -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:stashTests/ChangeSalaryVMTests/testSaveIsNoOpWhenInvalid
```

Confirm it's green (or red-then-fixed) before adding the next test. A test you haven't run isn't done.

## Keep tests in sync with the code

**When you change a function, update its tests in the same change — never separately.** A behavioral change to a VM/model method (signature, calculation, validation rule, new branch) means:
1. Update or add the affected test(s) alongside the code edit, in the same commit.
2. Re-run those tests with `-only-testing:` and confirm green.
3. If a change makes an assertion obsolete, fix the assertion to match the *intended* new behavior — don't delete the test to make it pass.

A code change that leaves tests untouched is incomplete; treat failing/stale tests as part of the same task, not a follow-up.

## What to test

**View models (pure logic) — the priority.** They're `@MainActor`, so mark tests `@MainActor`. Cover:
- Derived values: `monthlySaving` for both `.percentage` and `.fixed`, formatting (`serbianFormatted`).
- Validation flags: `savingExceedsSalary`, `canSave` / `canContinue` at and around the boundary (saving == salary, > salary, salary == 0).
- Parsing edge cases: `parsedSerbianNumber` on `"20.000"`, empty, junk.

```swift
@MainActor
final class ChangeSalaryVMTests: XCTestCase {
    func testSavingCannotExceedSalary() {
        let vm = ChangeSalaryVM()
        vm.salaryText = "3.000"
        vm.savingMethod = .fixed
        vm.fixedAmountText = "20.000"
        XCTAssertTrue(vm.savingExceedsSalary)
        XCTAssertFalse(vm.canSave)
    }
}
```

**SwiftData — use an in-memory container** so tests are isolated and fast:
```swift
@MainActor
func makeContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: UserProfile.self, FixedExpenseEntity.self, configurations: config)
    return container.mainContext
}
```
Then assert lookup/persistence behavior: `UserProfile.current(in:)` creates exactly one record, `existing(in:)` returns `nil` before creation, cascade delete removes child `FixedExpenseEntity` rows, a `save → fetch` round-trips values.

**Async VM methods.** `load`/`save` are `async` — `await` them in `async` test methods:
```swift
func testLoadPrefillsForm() async throws {
    let context = try makeContext()
    UserProfile.current(in: context).monthlySalary = 50_000
    let vm = ChangeSalaryVM()
    await vm.load(from: context)
    XCTAssertEqual(vm.monthlySalary, 50_000)
}
```

## Conventions
- One test = one behavior; name `test<Behavior>` clearly.
- Test boundaries and invalid input, not just the happy path.
- Keep views thin so logic stays unit-testable in the VM (don't put calculations in `body`).
- UI tests (`stashUITests`): smoke-test critical flows (onboarding completion → dashboard) sparingly; prefer fast VM unit tests for logic.

## Checklist
- [ ] VM logic/validation covered at boundaries
- [ ] SwiftData tested with `isStoredInMemoryOnly: true`
- [ ] `async` methods awaited in `async` tests; `@MainActor` on VM tests
- [ ] Each new/edited test run with `-only-testing:` and green before moving on
- [ ] Changed a function? Its tests were updated and re-run in the same change
- [ ] Test classes UpperCamelCase; `swiftlint --strict` clean
