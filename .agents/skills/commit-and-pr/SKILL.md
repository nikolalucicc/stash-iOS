---
name: commit-and-pr
description: Git workflow for the Stash iOS app — branching, pre-commit linting, commit messages, and opening pull requests. Use when committing changes, creating a branch, or preparing a PR, so work passes the SwiftLint pre-push hook and CI.
---

# Commit & PR workflow (Stash iOS)

Feature branches → PR into `main`. CI (`.github/workflows/ci.yml`) runs **SwiftLint (`--strict`)** and **build & test** on every push and PR. A SwiftLint **pre-push hook** also blocks pushes locally.

## Before committing

1. **Lint first** — the most common reason a push fails:
   ```bash
   cd stash && swiftlint --strict
   ```
   Fix any violations (see the `swiftlint-fix` skill) before going further.
2. Make sure it builds/tests if you changed logic:
   ```bash
   xcodebuild test -project stash/stash.xcodeproj -scheme stash \
     -destination 'platform=iOS Simulator,name=iPhone 16'
   ```

## Branching

- Never commit straight to `main`. Branch first.
- Use short, kebab-case, descriptive names matching existing history: `onboarding-steps`, `saving-user-data`, `readme-update`, `salary-change`.
- One branch = one focused change.

## Commit messages

- Short imperative subject describing the change, matching repo style: `Onboarding steps implementation`, `Saving users data locally and dashboard view`, `Update README.md`.
- Keep lint-only follow-ups explicit (the repo uses `Lint fix`, `Lint fix 2`...), but prefer to lint **before** committing so you don't need them.
- Only commit when the user asks. Don't add co-author/attribution trailers unless the user's convention requires it (this repo's history has none).

## Pull requests

- Open PRs into `main` with `gh`:
  ```bash
  gh pr create --base main --title "<summary>" --body "<what & why>"
  ```
- Confirm CI (SwiftLint + Build & Test) is green before requesting merge.
- History merges via GitHub PRs (`Merge pull request #N from <user>/<branch>`) — keep that flow.

## Checklist
- [ ] On a feature branch, not `main`
- [ ] `swiftlint --strict` clean locally
- [ ] Builds / tests pass if logic changed
- [ ] Focused commit with an imperative subject
- [ ] PR targets `main`; CI green before merge
