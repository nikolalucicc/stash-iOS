# Stash 💰

> **Stash** ti pomaže da odvojiš štednju čim legne plata — pre nego što je potrošiš. Uneseš platu, app ti pokaže šta ide na štednju, šta na fiksne troškove, a šta ostaje za život; pratiš „štek", ciljeve/želje i dnevnu potrošnju.

---

## O projektu

Stash je iOS aplikacija (SwiftUI) za jednostavno upravljanje mesečnom štednjom i budžetom. Filozofija je **„plati sebi prvo"** — čim legne plata, aplikacija odmah izračunava raspodelu između štednje, fiksnih troškova i slobodnog novca, a onda ti pomaže da: skupiš za konkretne želje, gomilaš opšti „štek" i pratiš na šta trošiš.

Svi podaci žive **lokalno na uređaju** (SwiftData). Jedini mrežni poziv je dohvat javnih kurseva valuta (bez ličnih podataka).

Projekat je razvijan kao lična vežba kroz ceo životni ciklus mobilne aplikacije: arhitektura → razvoj → testovi → CI/CD → release na TestFlight/App Store.

> Napomena: aplikacija je trenutno na **engleskom** jeziku. (Android verzija je moguća buduća vizija; ovaj repo je iOS.)

---

## Funkcionalnosti

Aplikacija ima četiri taba: **Goals** · **Monthly** · **Spending** · **Account**.

### Onboarding (4 koraka)
Valuta → Plata + period isplate → Način štednje (procenat/fiksno) → Fiksni troškovi. Sva polja kreću prazna; izabrana valuta se prikazuje kroz celu app.

### 🎯 Goals (lista želja)
- Dodavanje cilja sa prioritetom i (opcionim) rokom
- **Mesečni doprinos se automatski računa iz roka** (cena ÷ broj meseci)
- Depoziti na cilj; **„kupi odmah iz šteka"** kada već imaš dovoljno
- **Budžet za ciljeve** sa raspodelom po prioritetu

### 📊 Monthly (dashboard)
- Raspodela plate: štednja / fiksni / slobodno
- **„Total stashed"** kartica (opšta ušteda)
- **Payday podsetnik** — kad legne plata, jednim tapom potvrdiš da si odvojio mesečnu uštedu (dodaje se u štek, jednom po mesecu)
- Dani do sledeće plate, lista fiksnih troškova

### 💳 Spending
- Loguješ dnevnu potrošnju u kategorije; oduzima se od **slobodnog novca** za tekući mesec
- **Dodavanje i brisanje kategorija** (naziv + izbor ikonice); brisanje kategorije briše i njene troškove
- Pregled potrošnje po kategoriji + lista unosa sa brisanjem

### ⚙️ Account
- Izmena plate i štednje
- **Valuta (RSD / EUR / USD)** sa **live konverzijom** svih iznosa (kurs sa interneta)
- „Redo setup" (briše sve i kreće ispočetka)
- Ponovno pokretanje vodiča (walkthrough)

### Ostalo
- **Walkthrough** na prvom startu
- **Live formatiranje iznosa** dok kucaš (npr. `85000` → `85.000`)

**Planirano** 🚧: notifikacije (podsetnik na platu), App lock (Face ID/PIN), istorija/grafikoni, export (CSV/PDF).

---

## Arhitektura

**MVVM** sa `@Observable` ViewModelima, **SwiftData** za perzistenciju, deljeni dizajn sloj.

```
stash/stash/
├── stashApp.swift                  # Entry point — modelContainer(for:)
├── Models/                         # SwiftData @Model + domenski enum-ovi
│   ├── UserProfile.swift           #   Profil (plata, štednja, valuta, štek, flag-ovi)
│   ├── FixedExpenseEntity.swift    #   Fiksni trošak
│   ├── SavingsGoal.swift           #   Cilj / želja
│   ├── SpendingEntry.swift         #   Zabeležena potrošnja
│   ├── SpendingCategory.swift      #   Kategorija potrošnje (dodaje/briše korisnik)
│   └── PayPeriod.swift             #   Period isplate (enum)
├── Services/
│   └── ExchangeRateService.swift   # Live kursevi (open.er-api.com)
├── Theme/
│   ├── AppTheme.swift              # Boje, tipografija, Spacing, Radius
│   ├── Extensions.swift            # Number/String helperi
│   └── ThousandsGrouping.swift     # .thousandsGrouped(_:) live formatiranje
├── Views/
│   ├── RootView.swift              # Onboarding vs. glavni app
│   ├── MainTabView.swift           # Tabovi + first-run walkthrough
│   ├── Onboarding/                 # 4 koraka + ViewModels
│   ├── Goals/ · Stash/ · Spending/ · Account/ · ChangeSalaryData/ · Walkthrough/
│   ├── DashboardView.swift (+ DashboardComponents.swift)
│   └── Components/                 # DropdownPicker, OnboardingAppBar, ProgressIndicator
└── en.lproj/Localizable.strings    # Engleski
```

**Perzistencija:** jedan `UserProfile` po uređaju (`UserProfile.current(in:)` / `.existing(in:)`); UI čita preko `@Query` i osvežava se na `save()`. Svaki stored property ima default vrednost u deklaraciji da bi SwiftData „lightweight" migracija radila bez gubitka podataka pri promeni sheme.

---

## Tech Stack (iOS)

| Tehnologija | Svrha |
|---|---|
| SwiftUI | UI |
| SwiftData | Lokalna baza |
| Swift Concurrency | Async operacije |
| URLSession | Dohvat kursa valuta |
| XCTest | Unit testovi |
| Fastlane | Build + upload na TestFlight |

---

## Lokalni setup

```bash
git clone https://github.com/nikolalucicc/stash-iOS.git
cd stash-iOS
open stash/stash.xcodeproj      # Xcode 16+

# Lint (isto što i CI radi)
brew install swiftlint
swiftlint --strict              # iz root-a repozitorijuma
```

> SwiftLint se pokreće i kroz **pre-push git hook** — push se odbija ako ima violations.

Zahtevi: Xcode 16+, macOS Sonoma ili noviji, SwiftLint.

---

## Testovi

Unit testovi pokrivaju ViewModele i modele (onboarding, plata, ciljevi, štek, potrošnja, payday, valuta, formatiranje).

```bash
xcodebuild test \
  -project stash/stash.xcodeproj \
  -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:stashTests
```

---

## CI/CD

Pipeline ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) na **`pull_request`**:
- **`lint`** → `swiftlint --strict` na `ubuntu-latest` (Docker image, bez macOS minuta)
- **`build-and-test`** → `macos-15` + Xcode 16.4 → `xcodebuild test`

`main` je zaštićen: **force-push i brisanje blokirani**, **PR obavezan**, **CI mora zeleno** pre merge-a.

Release: [`.github/workflows/release.yml`](.github/workflows/release.yml) pokreće `fastlane beta` na `v*` tag ili ručno.

---

## Objavljivanje na TestFlight

Kod je spreman (app ikonica, export-compliance, Fastlane). Sledeći koraci su na Apple/GitHub strani. Detalji i tačne komande: [`fastlane/README.md`](fastlane/README.md).

**Bundle ID:** `ios.projects.stash` · **verzija:** 1.0 (build se automatski podiže).

1. **Apple Developer Program** — aktivan plaćeni nalog ($99/god).
2. **App ID + App record** — registruj `ios.projects.stash` (Developer portal → Identifiers), pa napravi aplikaciju u **App Store Connect** (Apps → New App, iOS, ime „Stash", bundle `ios.projects.stash`).
3. **App Store Connect API ključ** — Users and Access → Integrations → generiši ključ (**App Manager**), preuzmi `.p8`, zapamti **Key ID** i **Issuer ID**.
4. **Lokalni Ruby** — `rbenv install 3.2 && bundle install`.
5. **`match` (sertifikati)** — napravi prazan **privatan** repo (npr. `stash-certificates`), postavi env i pokreni:
   ```bash
   export ASC_KEY_ID=... ASC_ISSUER_ID=... ASC_KEY_CONTENT="$(base64 -i AuthKey_XXX.p8)"
   export MATCH_GIT_URL=... MATCH_PASSWORD=...
   bundle exec fastlane match appstore
   ```
6. **Slanje build-a na TestFlight:**
   - lokalno: `bundle exec fastlane beta`
   - ili iz CI-ja: dodaj GitHub secrets (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`, `MATCH_GIT_URL`, `MATCH_PASSWORD`, `MATCH_GIT_BASIC_AUTHORIZATION`) pa `git tag v1.0.0 && git push origin v1.0.0`.
7. **TestFlight** — build se pojavi u App Store Connect → TestFlight (par minuta procesiranja) → dodaj internal testere (do 100, bez review-a) → instaliraju preko TestFlight app-a.

### Dalje — App Store
Screenshot-ovi (6.7"/6.9" iPhone) · opis + keywords · **Privacy Policy URL** · „App Privacy" upitnik (praktično „Data Not Collected") · **Submit for Review**.

---

## Roadmap

- [x] Onboarding, dizajn sistem, lokalno čuvanje (SwiftData)
- [x] Dashboard (raspodela plate), štek, payday podsetnik
- [x] Ciljevi / lista želja (prioritet, rok, auto mesečni iznos, budžet)
- [x] Potrošnja po kategorijama (dodavanje/brisanje kategorija)
- [x] Valute + live konverzija
- [x] Walkthrough, live formatiranje iznosa
- [x] CI/CD + branch protection + Fastlane (TestFlight)
- [ ] Notifikacije (podsetnik na platu)
- [ ] App lock (Face ID / PIN)
- [ ] Istorija + grafikoni
- [ ] Export (CSV / PDF)
- [ ] App Store release

---

## Licenca

MIT License — slobodno koristi, menjaj i distribuiraj.
