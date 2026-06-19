# Stash 💰

> **Stash** ti pomaže da odvojiš štednju čim legne plata — pre nego što je potrošiš. Uneseš iznos, app ti kaže šta ide na štednju, šta na fiksne troškove, šta ostaje za život. Ništa više, ništa manje.

---

## O projektu

Stash je mobilna aplikacija za Android i iOS namenjena jednostavnom upravljanju mesečnom štednjom. Filozofija aplikacije je **"plati sebi prvo"** — čim legne plata, korisnik unosi iznos i aplikacija odmah izračunava raspodelu između štednje, fiksnih troškova i slobodnog novca.

Projekat je razvijen kao lična vežba sa ciljem upoznavanja sa celim životnim ciklusom mobilne aplikacije: od arhitekture i razvoja, kroz testove i CI/CD pipeline, do release procesa na Google Play Store i Apple App Store.

> **Napomena:** Ovo je **iOS** repozitorijum (SwiftUI). Deo dokumenta opisuje ciljnu viziju za obe platforme; aktuelno stanje iOS implementacije je u sekciji [Trenutni status](#trenutni-status-ios).

---

## Trenutni status (iOS)

Implementirano do sada:

- ✅ **Onboarding (4 koraka)**
  1. Unos plate + period isplate (početak / sredina / kraj meseca)
  2. Način štednje — procenat plate ili fiksni iznos, sa live pregledom mesečne štednje
  3. Fiksni troškovi — dodavanje/brisanje preko sheet-a, sa automatskim biranjem ikonice po nazivu
  4. Izbor valute (RSD / EUR / USD)
- ✅ **Lokalno čuvanje (SwiftData)** — `UserProfile` + `FixedExpenseEntity` modeli; podaci uneti u onboarding-u se čuvaju na uređaju i učitavaju nazad pri ponovnom otvaranju
- ✅ **Dashboard** — pregled sačuvanog profila: plata, raspodela (štednja / fiksni / slobodno), mesečna ušteda, dani do sledeće plate, lista fiksnih troškova
- ✅ **Rutiranje na startu** — `RootView` vodi na dashboard ili onboarding u zavisnosti od `onboardingCompleted` flag-a
- ✅ **Dizajn sistem** — `AppTheme` (boje, Inter tipografija, `Spacing` i `Radius` tokeni) + `StashTheme` pozadinski wrapper
- ✅ **Reusable komponente** — `DropdownPicker`, `OnboardingAppBar`, `ProgressIndicator`
- ✅ **MVVM** — `@Observable @MainActor` ViewModel po koraku
- ✅ **Lokalizacija** — engleski (default) + srpski (`Localizable.strings`, `LocalizedStringKey`)
- ✅ **SwiftLint** — konfiguracija + pre-push hook + GitHub Actions CI

Sledeće na redu: istorija mesečnih entrija, notifikacije, podešavanja.

---

## Funkcionalnosti (ciljna vizija)

- 📥 **Unos plate** — uneseš iznos, aplikacija odmah računa raspodelu ✅
- 🎯 **Cilj štednje** — fiksni iznos ili procenat plate ✅
- 🧾 **Fiksni troškovi** — kirija, rate, pretplate — automatski se uračunavaju ✅
- 📊 **Dashboard** — pregled tekućeg meseca i raspodele plate ✅
- 📅 **Istorija** — mesečni i godišnji pregled svih entrija 🚧
- 🔥 **Streak tracker** — broj uzastopnih meseci sa unetom platom 🚧
- 🔔 **Notifikacije** — podsetnik na dan isplate 🚧
- 🔒 **App lock** — biometrija ili PIN 🚧
- 💾 **Export** — CSV i PDF izveštaji, lokalni backup 🚧
- 🌙 **Dark mode** — trenutno fiksno dark 🚧

Svi podaci su lokalni — aplikacija ne šalje ništa na server. _(✅ = urađeno, 🚧 = planirano)_

---

## Tech Stack

### Android
| Tehnologija | Svrha |
|---|---|
| Kotlin + Jetpack Compose | UI |
| Room | Lokalna baza |
| Hilt | Dependency injection |
| DataStore | User preferences |
| WorkManager | Scheduled notifikacije |
| JUnit5 + MockK | Unit testovi |
| Compose Testing | UI testovi |

### iOS
| Tehnologija | Svrha |
|---|---|
| SwiftUI | UI |
| SwiftData | Lokalna baza |
| Swift Concurrency | Async operacije |
| XCTest + Swift Testing | Unit i UI testovi |

---

## Arhitektura

### Aktuelna struktura (iOS)

Trenutno je u upotrebi **MVVM** sa `@Observable` ViewModelima, **SwiftData** slojem za perzistenciju i deljenim dizajn slojem:

```
stash/stash/
├── stashApp.swift              # Entry point — postavlja modelContainer
├── Models/                     # SwiftData @Model klase
│   ├── UserProfile.swift       #   Profil (plata, štednja, valuta, flag-ovi)
│   └── FixedExpenseEntity.swift#   Fiksni trošak (relacija ka profilu)
├── Theme/
│   ├── AppTheme.swift          # Boje, tipografija, Spacing, Radius
│   └── Extensions.swift        # NumberFormatter / Double / String helperi
├── Views/
│   ├── RootView.swift          # Rutiranje: dashboard vs. onboarding
│   ├── DashboardView.swift     # Pregled sačuvanog profila
│   ├── Components/             # DropdownPicker, OnboardingAppBar,
│   │                          #   ProgressIndicator, StashTheme
│   └── Onboarding/
│       ├── Onboarding{First…Fourth}StepView.swift
│       └── ViewModels/         # @Observable @MainActor VM po koraku
├── en.lproj/Localizable.strings   # Engleski (default)
└── sr.lproj/Localizable.strings   # Srpski
```

**Perzistencija:** `modelContainer(for:)` se postavlja u `StashApp`, a `UserProfile` se čuva po principu „jedan profil po uređaju" (`UserProfile.current(in:)` / `.existing(in:)`). Onboarding koraci upisuju podatke u profil, a `RootView` na startu čita `onboardingCompleted` da odluči koji ekran prikazati.

### Ciljna arhitektura

Kako projekat raste, prelazi se na **Clean Architecture** sa tri odvojena layera:

```
├── data/
│   ├── local/          # Baza, DAO-i, entitiji
│   └── repository/     # Implementacije repozitorijuma
├── domain/
│   ├── model/          # Čisti domain modeli
│   ├── repository/     # Interfejsi
│   └── usecase/        # Poslovna logika
└── presentation/
    ├── screen/         # Ekrani i ViewModeli
    └── navigation/     # Navigacija
```

### Use Cases

| Use Case | Opis |
|---|---|
| `SetupUserProfileUseCase` | Inicijalno podešavanje profila |
| `ManageFixedExpensesUseCase` | Upravljanje fiksnim troškovima |
| `CalculateSalaryAllocationUseCase` | Kalkulacija raspodele plate |
| `RecordMonthlyEntryUseCase` | Čuvanje mesečnog entrija |
| `GetSavingsProgressUseCase` | Agregacija statistika štednje |
| `GetCurrentMonthStatusUseCase` | Status tekućeg meseca |

---

## CI/CD

### Android
- **PR** → lint (ktlint) + unit testovi + debug build
- **Merge u main** → release build (potpisani AAB) + auto-upload na Play Store Internal Testing track

### iOS
Aktuelni pipeline ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) na `push` i `pull_request`:
- **`lint`** → `swiftlint --strict`
- **`build-and-test`** → `xcodebuild test` (scheme `stash`, iPhone 16 simulator), uz upload test rezultata pri padu

Planirano: archive + automatski upload na TestFlight preko **Fastlane**, sa sertifikatima i provisioning profilima kroz **Fastlane match**.

---

## Lokalni setup

### Android

```bash
# Kloniranje repozitorijuma
git clone https://github.com/username/stash-android.git
cd stash-android

# Build
./gradlew assembleDebug

# Testovi
./gradlew test
./gradlew connectedAndroidTest
```

### iOS

```bash
# Kloniranje repozitorijuma
git clone https://github.com/nikolalucicc/stash-iOS.git
cd stash-iOS

# Otvaranje u Xcode
open stash/stash.xcodeproj

# Lint (lokalno, isto što i CI radi)
brew install swiftlint   # ako već nije instaliran
cd stash && swiftlint --strict
```

> SwiftLint se pokreće i kroz **pre-push git hook** — push se odbija ako ima violations. Pokreni `swiftlint --strict` pre push-a da uhvatiš greške ranije.

Zahtevi:
- Android: Android Studio Hedgehog ili noviji, JDK 17+
- iOS: Xcode 15+, macOS Sonoma ili noviji, SwiftLint

---

## Testovi

Ciljna pokrivenost: **70%+ na domain i data layeru**.

```bash
# Android — unit testovi
./gradlew test

# Android — coverage report
./gradlew koverHtmlReport

# iOS — testovi
xcodebuild test \
  -project stash/stash.xcodeproj \
  -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Release

| Platforma | Status |
|---|---|
| Google Play Store | 🚧 In progress |
| Apple App Store | 🚧 In progress |

---

## Roadmap

**V1 — MVP (iOS)**
- [x] Dizajn sistem i reusable komponente
- [x] Onboarding (4 koraka)
- [x] Lokalizacija (en + sr)
- [x] CI/CD pipeline (SwiftLint + build & test)
- [x] Lokalno čuvanje podataka (SwiftData)
- [x] Dashboard
- [ ] Unos plate i kalkulacija (van onboarding-a)
- [ ] Istorija
- [ ] Podešavanja
- [ ] Notifikacije
- [ ] App lock
- [ ] Play Store + App Store release

**V2**
- [ ] Štedni džepovi (named savings goals)
- [ ] Projekcija dostizanja cilja
- [ ] Godišnji pregled
- [ ] Export (CSV + PDF)
- [ ] Lokalni backup i restore

**V3**
- [ ] Višestruki prihodi
- [ ] Cloud sync između uređaja

---

## Licenca

MIT License — slobodno koristi, menjaj i distribuiraj.
