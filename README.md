# Stash 💰

> **Stash** ti pomaže da odvojiš štednju čim legne plata — pre nego što je potrošiš. Uneseš platu, app ti kaže šta ide na štednju, šta na fiksne troškove, šta ostaje za život, i pomaže ti da skupiš za ono što želiš.

---

## O projektu

Stash je mobilna aplikacija za Android i iOS namenjena jednostavnom upravljanju mesečnom štednjom. Filozofija aplikacije je **"plati sebi prvo"** — čim legne plata, korisnik unosi iznos i aplikacija odmah izračunava raspodelu između štednje, fiksnih troškova i slobodnog novca. Pored mesečne raspodele, app prati i **ciljeve štednje** (lista želja) i opšti **„štek"** — novac koji si odvojio, a nije vezan za konkretan cilj.

Projekat je razvijen kao lična vežba sa ciljem upoznavanja sa celim životnim ciklusom mobilne aplikacije: od arhitekture i razvoja, kroz testove i CI/CD pipeline, do release procesa na Google Play Store i Apple App Store.

> **Napomena:** Ovo je **iOS** repozitorijum (SwiftUI). Deo dokumenta opisuje ciljnu viziju za obe platforme; aktuelno stanje iOS implementacije je u sekciji [Trenutni status](#trenutni-status-ios).

---

## Trenutni status (iOS)

Implementirano do sada:

- ✅ **Onboarding (4 koraka)** — valuta se bira **prva**, pa svi sledeći koraci prikazuju izabranu valutu:
  1. **Valuta** (RSD / EUR / USD)
  2. **Plata** + period isplate (početak / sredina / kraj meseca)
  3. **Način štednje** — procenat plate ili fiksni iznos, sa live pregledom mesečne štednje
  4. **Fiksni troškovi** — dodavanje/brisanje preko sheet-a, sa automatskim biranjem ikonice po nazivu
- ✅ **Tab navigacija** — `Ciljevi` / `Mesečno` / `Nalog`
- ✅ **Ciljevi (lista želja)** — dodavanje cilja sa prioritetom i rokom; **mesečni doprinos se automatski računa iz roka** (cena / broj meseci do roka); depoziti na cilj; **„kupi odmah iz šteka"** kad već imaš dovoljno; **budžet za ciljeve** sa raspodelom po prioritetu
- ✅ **Štek (opšta ušteda)** — kartica „Total stashed" na `Mesečno` tabu; dodaj iznos ili postavi trenutno stanje
- ✅ **Dashboard (Mesečno)** — plata, raspodela (štednja / fiksni / slobodno), štek, mesečna ušteda, dani do sledeće plate, lista fiksnih troškova
- ✅ **Nalog (podešavanja)** — izmena plate i štednje, izbor valute sa **live konverzijom svih iznosa** (kursevi sa interneta), „redo setup" (briše sve podatke i kreće ispočetka), ponovno pokretanje vodiča
- ✅ **Valutna konverzija** — promenom valute se povuče live kurs (`open.er-api.com`) i **konvertuju svi iznosi** (plata, troškovi, ciljevi, budžet, štek)
- ✅ **Walkthrough** — kratak vodič kroz ekrane na prvom startu, sa opcijom da se ponovo pokrene iz `Nalog`-a
- ✅ **Live formatiranje iznosa** — dok kucaš, vodeća nula se briše i „." se ubacuje na svake 3 cifre (npr. `85000` → `85.000`)
- ✅ **Lokalno čuvanje (SwiftData)** — `UserProfile`, `FixedExpenseEntity`, `SavingsGoal` modeli; svi podaci ostaju na uređaju
- ✅ **Dizajn sistem** — `AppTheme` (boje, Inter tipografija, `Spacing` i `Radius` tokeni) + `StashTheme` pozadinski wrapper
- ✅ **Reusable komponente** — `DropdownPicker`, `OnboardingAppBar`, `ProgressIndicator`, `.thousandsGrouped(_:)` modifier
- ✅ **MVVM** — `@Observable @MainActor` ViewModeli
- ✅ **Lokalizacija** — engleski (default) + srpski (`Localizable.strings`, en/sr paritet)
- ✅ **SwiftLint + CI** — `swiftlint --strict` (pre-push hook + GitHub Actions), `lint` + `build & test` job; `main` zaštićena branch protection-om

Sledeće na redu: istorija mesečnih entrija, notifikacije (podsetnik na platu), App lock (Face ID / PIN).

---

## Funkcionalnosti (ciljna vizija)

- 📥 **Unos plate** — uneseš iznos, aplikacija odmah računa raspodelu ✅
- 🎯 **Cilj štednje** — fiksni iznos ili procenat plate ✅
- 🧾 **Fiksni troškovi** — kirija, rate, pretplate — automatski se uračunavaju ✅
- 📊 **Dashboard** — pregled tekućeg meseca i raspodele plate ✅
- ⭐ **Lista želja (ciljevi)** — štednja po prioritetu, sa rokom i auto-računatim mesečnim iznosom ✅
- 🐷 **Štek** — opšta ušteda van ciljeva ✅
- 💱 **Valute** — RSD / EUR / USD sa live konverzijom ✅
- 🧭 **Walkthrough** — vodič kroz aplikaciju ✅
- 📅 **Istorija** — mesečni i godišnji pregled svih entrija 🚧
- 🔥 **Streak tracker** — broj uzastopnih meseci sa unetom platom 🚧
- 🔔 **Notifikacije** — podsetnik na dan isplate 🚧
- 🔒 **App lock** — biometrija ili PIN 🚧
- 💾 **Export** — CSV i PDF izveštaji, lokalni backup 🚧
- 🌙 **Dark mode** — trenutno fiksno dark 🚧

Svi lični podaci su lokalni — aplikacija ih ne šalje na server. Jedini mrežni poziv je dohvat javnih kurseva valuta (bez ličnih podataka). _(✅ = urađeno, 🚧 = planirano)_

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
| URLSession | Dohvat kursa valuta |
| XCTest | Unit testovi |

---

## Arhitektura

### Aktuelna struktura (iOS)

Trenutno je u upotrebi **MVVM** sa `@Observable` ViewModelima, **SwiftData** slojem za perzistenciju i deljenim dizajn slojem:

```
stash/stash/
├── stashApp.swift                  # Entry point — postavlja modelContainer
├── Models/                         # SwiftData @Model klase
│   ├── UserProfile.swift           #   Profil (plata, štednja, valuta, štek, flag-ovi)
│   ├── FixedExpenseEntity.swift    #   Fiksni trošak (relacija ka profilu)
│   └── SavingsGoal.swift           #   Cilj / želja (prioritet, rok, ušteđeno)
├── Services/
│   └── ExchangeRateService.swift   # Live kursevi valuta (open.er-api.com)
├── Theme/
│   ├── AppTheme.swift              # Boje, tipografija, Spacing, Radius
│   ├── Extensions.swift            # NumberFormatter / Double / String helperi
│   └── ThousandsGrouping.swift     # .thousandsGrouped(_:) live formatiranje iznosa
├── Views/
│   ├── RootView.swift              # Rutiranje: onboarding vs. glavni app
│   ├── MainTabView.swift           # Tabovi + first-run walkthrough
│   ├── DashboardView.swift         # Pregled meseca (+ DashboardComponents.swift)
│   ├── Components/                 # DropdownPicker, OnboardingAppBar, ProgressIndicator
│   ├── Onboarding/                 # 4 koraka + ViewModels (@Observable @MainActor)
│   ├── Goals/                      # Lista želja, dodaj/izmeni cilj, budžet, detalj
│   ├── Stash/                      # Štek (StashVM, StashDepositSheet)
│   ├── Account/                    # Podešavanja (AccountVM)
│   ├── ChangeSalaryData/           # Izmena plate i štednje
│   └── Walkthrough/                # First-run tour
├── en.lproj/Localizable.strings    # Engleski (default)
└── sr.lproj/Localizable.strings    # Srpski
```

**Perzistencija:** `modelContainer(for:)` se postavlja u `StashApp`, a `UserProfile` se čuva po principu „jedan profil po uređaju" (`UserProfile.current(in:)` / `.existing(in:)`). `RootView` na startu čita `onboardingCompleted` da odluči koji ekran prikazati, a `MainTabView` `walkthroughCompleted` da pusti vodič.

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
Aktuelni pipeline ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) na **`pull_request`** (merge-ovi u `main` su već prošli kroz PR, pa se push ne pokreće dvaput):
- **`lint`** → `swiftlint --strict` na `ubuntu-latest` preko zvaničnog SwiftLint Docker image-a (Linux, bez macOS minuta)
- **`build-and-test`** → `macos-15` + Xcode 16.4, kreira iOS simulator i pokreće `xcodebuild test` (scheme `stash`), uz upload test rezultata pri padu

`main` grana je zaštićena: **force-push i brisanje su blokirani**, **PR je obavezan** pre merge-a, a **CI mora da bude zelen** (`SwiftLint` + `Build & Test`).

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
swiftlint --strict       # iz root-a repozitorijuma
```

> SwiftLint se pokreće i kroz **pre-push git hook** — push se odbija ako ima violations. Pokreni `swiftlint --strict` pre push-a da uhvatiš greške ranije.

Zahtevi:
- Android: Android Studio Hedgehog ili noviji, JDK 17+
- iOS: Xcode 16+, macOS Sonoma ili noviji, SwiftLint

---

## Testovi

Ciljna pokrivenost: **70%+ na logici/data layeru**. Unit testovi pokrivaju ViewModele (onboarding, plata, ciljevi, štek, nalog), alokaciju budžeta po prioritetu i formatiranje iznosa.

```bash
# Android — unit testovi
./gradlew test

# Android — coverage report
./gradlew koverHtmlReport

# iOS — testovi (zameni imenom simulatora koji imaš)
xcodebuild test \
  -project stash/stash.xcodeproj \
  -scheme stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:stashTests
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
- [x] Onboarding (valuta → plata → štednja → troškovi)
- [x] Lokalizacija (en + sr)
- [x] CI/CD pipeline (SwiftLint + build & test) + branch protection
- [x] Lokalno čuvanje podataka (SwiftData)
- [x] Dashboard (Mesečno)
- [x] Ciljevi / lista želja (prioritet, rok, auto mesečni iznos, depoziti)
- [x] Štek (opšta ušteda)
- [x] Valute + live konverzija
- [x] Nalog / podešavanja (plata, valuta, redo setup)
- [x] Walkthrough
- [ ] Istorija
- [ ] Notifikacije
- [ ] App lock
- [ ] Play Store + App Store release

**V2**
- [ ] Projekcija dostizanja cilja kroz vreme
- [ ] Godišnji pregled
- [ ] Export (CSV + PDF)
- [ ] Lokalni backup i restore

**V3**
- [ ] Višestruki prihodi
- [ ] Cloud sync između uređaja

---

## Licenca

MIT License — slobodno koristi, menjaj i distribuiraj.
