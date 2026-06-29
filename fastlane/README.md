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

## Shared signing with `match`

So CI (and other machines) can sign without manual certificate juggling,
signing assets live encrypted in a **separate private git repo**.

One-time, on your machine:

```bash
# 1. Create an empty PRIVATE repo, e.g. github.com/nikolalucicc/stash-certificates
export MATCH_GIT_URL="https://github.com/nikolalucicc/stash-certificates.git"
export MATCH_PASSWORD="a-strong-passphrase"     # encrypts the repo contents

# 2. Generate + store the App Store certificate & profile
bundle exec fastlane match appstore
```

After that, `fastlane beta` (locally or in CI) fetches them automatically —
on CI in `readonly` mode, so it never regenerates anything.

## GitHub Actions release

`.github/workflows/release.yml` runs `fastlane beta` on a tag push (`v*`) or
manual dispatch. Add these **repository secrets** (Settings → Secrets and
variables → Actions):

| Secret | Value |
|---|---|
| `ASC_KEY_ID` | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | API Issuer ID |
| `ASC_KEY_CONTENT` | base64 of the `.p8` key |
| `MATCH_GIT_URL` | HTTPS URL of the private certificates repo |
| `MATCH_PASSWORD` | match encryption passphrase |
| `MATCH_GIT_BASIC_AUTHORIZATION` | base64 of `username:personal_access_token` with read access to the certs repo |

Then ship a build by pushing a tag:

```bash
git tag v1.0.0 && git push origin v1.0.0
```
