# Fastlane

Automates building and uploading **Stash** to TestFlight.

## Lanes

| Lane | What it does |
|---|---|
| `fastlane beta` | Bumps the build number, builds an App Store release archive and uploads it to TestFlight. |
| `fastlane tests` | Runs the unit tests (`stashTests`), same set as CI. |

## One-time setup

1. **Ruby + dependencies**

   Fastlane needs a recent Ruby (the macOS system Ruby 2.6 is too old). With
   `rbenv`:

   ```bash
   brew install rbenv
   rbenv install 3.2.2 && rbenv local 3.2.2
   gem install bundler
   bundle install
   ```

2. **App Store Connect API key** (recommended — avoids Apple ID + 2FA)

   App Store Connect → Users and Access → **Integrations / Keys** → create a key
   with the **App Manager** role and download the `.p8`. Then export:

   ```bash
   export ASC_KEY_ID="XXXXXXXXXX"          # the Key ID
   export ASC_ISSUER_ID="xxxxxxxx-xxxx-…"  # the Issuer ID
   export ASC_KEY_CONTENT="$(base64 -i AuthKey_XXXXXXXXXX.p8)"
   ```

   (Never commit the `.p8` — it's git-ignored.)

3. **Code signing**

   For a first local run, open the project in Xcode once with **Automatically
   manage signing** enabled and your team selected so a distribution
   certificate + App Store provisioning profile exist. For CI/reproducible
   signing, switch to [`match`](https://docs.fastlane.tools/actions/match/)
   later (needs a private certificates repo).

## Run

```bash
bundle exec fastlane beta
```

The build appears in App Store Connect → TestFlight after a few minutes of
processing, ready for internal testers.
