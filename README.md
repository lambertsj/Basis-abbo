# Opzegwekker

Gratis iOS-app die je een seintje geeft vóórdat een proefperiode afloopt of een abonnement verlengt. Een BasisApp:

- geen netwerkverkeer en geen account;
- geen tracking en geen in-app aankopen;
- alle gegevens blijven lokaal in SwiftData.

## Openen en bouwen

1. Open `Opzegwekker.xcodeproj` in Xcode 16 of nieuwer.
2. Kies bij de targets `Opzegwekker` en `OpzegwekkerWidget` je team onder *Signing & Capabilities*.
3. Pas zo nodig `APP_BUNDLE_ID` aan in de build-instellingen van het project (standaard `nl.basisapps.opzegwekker`). App Group, widget-ID en achtergrondtaak volgen daar automatisch uit.
4. Bouw en draai het schema `Opzegwekker`. Testdata laad je in DEBUG via het launch-argument `-OpzegwekkerSeed` of via Instellingen → Testdata laden.

Opent het project niet, dan genereer je het opnieuw met [XcodeGen](https://github.com/yonaskolb/XcodeGen): `xcodegen generate`.

## Tests

De domeinlaag is pure Swift zonder SwiftUI of UserNotifications. De tests (Swift Testing) draaien op twee manieren:

- in Xcode: ⌘U op het schema `Opzegwekker`;
- zonder Xcode, ook op Linux: `swift test` (via `Package.swift`).

## Structuur

| Map | Inhoud |
| --- | --- |
| `Shared/Model/` | `CalendarDay`, `ItemData`, het SwiftData-model `Item` en de store in de App Group |
| `Shared/Domain/` | beslisdatums, seintjes, overgangen, groepering, maandtotaal, meldingsplanning, formulierlogica, CSV |
| `Shared/UI/` | letter-icoon en urgentiekleur (app en widget) |
| `Catalog/` | `services.json` en de loader |
| `Opzegwekker/App/` | app-start, `AppModel`, instellingen, debug-seed, assets, privacymanifest |
| `Opzegwekker/Notifications/` | `NotificationScheduler`, delegate voor acties, achtergrondtaak |
| `Opzegwekker/Features/` | Overzicht, Toevoegen, Detail, Instellingen, Kaarten |
| `OpzegwekkerWidget/` | kleine widget |
| `OpzegwekkerTests/` | tests |
| `Config/` | Info.plists en entitlements |
| `Design/` | logo als SVG (bron van het app-icoon) |

Zie `DECISIONS.md` voor alle keuzes die niet in de opdracht stonden, en `CATALOG_TODO.md` voor de catalogusvelden die nog nagelopen moeten worden.
