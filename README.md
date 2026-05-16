# Stash 💰

> **Stash** ti pomaže da odvojiš štednju čim legne plata — pre nego što je potrošiš. Uneseš iznos, app ti kaže šta ide na štednju, šta na fiksne troškove, šta ostaje za život. Ništa više, ništa manje.

---

## O projektu

Stash je mobilna aplikacija za Android i iOS namenjena jednostavnom upravljanju mesečnom štednjom. Filozofija aplikacije je **"plati sebi prvo"** — čim legne plata, korisnik unosi iznos i aplikacija odmah izračunava raspodelu između štednje, fiksnih troškova i slobodnog novca.

Projekat je razvijen kao lična vežba sa ciljem upoznavanja sa celim životnim ciklusom mobilne aplikacije: od arhitekture i razvoja, kroz testove i CI/CD pipeline, do release procesa na Google Play Store i Apple App Store.

---

## Funkcionalnosti

- 📥 **Unos plate** — uneseš iznos, aplikacija odmah računa raspodelu
- 🎯 **Cilj štednje** — fiksni iznos ili procenat plate
- 🧾 **Fiksni troškovi** — kirija, rate, pretplate — automatski se uračunavaju
- 📊 **Dashboard** — pregled tekućeg meseca i ukupne uštedine
- 📅 **Istorija** — mesečni i godišnji pregled svih entrija
- 🔥 **Streak tracker** — broj uzastopnih meseci sa unetom platom
- 🔔 **Notifikacije** — podsetnik na dan isplate
- 🔒 **App lock** — biometrija ili PIN
- 💾 **Export** — CSV i PDF izveštaji, lokalni backup
- 🌙 **Dark mode** — Light / Dark / System

Svi podaci su lokalni — aplikacija ne šalje ništa na server.

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

Oba projekta koriste **Clean Architecture** sa tri odvojena layera:

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
- **PR** → SwiftLint + unit testovi + build
- **Merge u main** → archive + automatski upload na TestFlight (Fastlane)

Sertifikati i provisioning profili se upravljaju putem **Fastlane match**.

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
git clone https://github.com/username/stash-ios.git
cd stash-ios

# Instalacija dependencies
bundle install

# Otvaranje u Xcode
open Stash.xcodeproj
```

Zahtevi:
- Android: Android Studio Hedgehog ili noviji, JDK 17+
- iOS: Xcode 15+, macOS Sonoma ili noviji

---

## Testovi

Ciljna pokrivenost: **70%+ na domain i data layeru**.

```bash
# Android — unit testovi
./gradlew test

# Android — coverage report
./gradlew koverHtmlReport

# iOS — testovi
xcodebuild test -scheme Stash -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Release

| Platforma | Status |
|---|---|
| Google Play Store | 🚧 In progress |
| Apple App Store | 🚧 In progress |

---

## Roadmap

**V1 — MVP**
- [x] Arhitektura i data layer
- [ ] Onboarding
- [ ] Dashboard
- [ ] Unos plate i kalkulacija
- [ ] Istorija
- [ ] Podešavanja
- [ ] Notifikacije
- [ ] App lock
- [ ] CI/CD pipeline
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
