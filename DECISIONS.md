# Keuzes

Hier staan de keuzes die niet in de opdracht stonden. Waar de opdracht niets zei, heb ik de optie gekozen met de minste frictie voor de gebruiker.

## Project en omgeving

1. **Het Xcode-project bestond nog niet.** De repository was leeg. Daarom heb ik `Opzegwekker.xcodeproj` zelf gemaakt, met de targets `Opzegwekker`, `OpzegwekkerWidget` en `OpzegwekkerTests`.
    - Het project gebruikt gesynchroniseerde mappen (`objectVersion 77`) en heeft dus Xcode 16 of nieuwer nodig.
    - Er is ook een gedeeld schema meegeleverd.
    - Mocht het project niet openen, dan kun je met `project.yml` (XcodeGen, alleen een bouwhulpmiddel) een nieuw project genereren.
2. **Bundle-ID.** Alles volgt uit één build-instelling: `APP_BUNDLE_ID = nl.basisapps.opzegwekker` op projectniveau. Daaruit volgen:
    - de widget (`.widget`) en de tests (`.tests`);
    - de App Group `group.$(APP_BUNDLE_ID).shared`;
    - de achtergrondtaak `$(APP_BUNDLE_ID).refresh`.

   De code leest de App Group en de taak-ID uit Info.plist, dus het wijzigen van die ene instelling is genoeg. `DEVELOPMENT_TEAM` is leeg; vul je eigen team in. Met automatisch ondertekenen maakt Xcode de App Group en de time-sensitive-capability zelf aan in je ontwikkelaarsaccount.
3. **Gebouwd zonder Xcode.** Ik werkte in een Linux-omgeving zonder Xcode en zonder iOS-SDK.
    - De pure kern (model-waardes, domeinlaag, catalogus) is ook een Swift Package (`Package.swift`). Daarmee draaien alle tests met `swift test`. Ik heb ze gedraaid met Swift 6.2: alles groen, 0 warnings.
    - De SwiftUI-, SwiftData-, WidgetKit- en UserNotifications-code heb ik zorgvuldig nagelezen, maar niet kunnen compileren. De eerste build in Xcode is dus de eerste echte controle daarvan.
4. **Mapindeling.**
    - `Shared/` (Model, Domain, plus `Shared/UI` voor letter-icoon en urgentiekleur) en `Catalog/` staan op het hoogste niveau, omdat app en widget ze allebei gebruiken.
    - `Notifications/`, `Features/` en `App/` staan in `Opzegwekker/`.
    - `Config/` bevat de Info.plists en entitlements.
5. **Swift 5-taalmodus** in Xcode en in het package. Zo blijven warnings rond strikte concurrency weg zonder dat de code er lastiger van wordt.
6. **Alleen iPhone, staand.** Dat is minder testoppervlak voor v1.
7. **`ITSAppUsesNonExemptEncryption = false`.** Dat scheelt een vraag bij elke upload.
8. **Bron-URL** in Over: `https://github.com/lambertsj/Basis-abbo`, de repository van dit project.

## Model en opslag

9. **`ItemData` als waardetype.** De domeinlaag werkt op een plain struct in plaats van op het `@Model`. Daardoor is ze zonder SwiftData te testen. Dezelfde struct dient als snapshot voor Ongedaan maken.
10. **Kalenderdagen** worden in SwiftData opgeslagen als `yyyy-MM-dd`-tekst, met getypte `CalendarDay`-accessors. Dat is robuuster dan samengestelde Codable-attributen, die in iOS 17 bekende problemen hadden. Enums staan erin als String raw values.
11. **Dagrekening** gebeurt met pure integer-rekenkunde (Gregoriaans). Er komt dus geen tijdzone aan te pas en niets kan falen. `Calendar` wordt alleen gebruikt om een dag om te zetten van en naar een `Date`.
12. **UserDefaults.** De app gebruikt de standaard UserDefaults en niet die van de App Group, want de widget heeft geen instellingen nodig. Daarom staat in beide privacymanifesten alleen `CA92.1`.

## Domeinregels

13. **Time-sensitive** is elk seintje dat op de beslisdatum zelf valt. Lead 0 valt daar altijd onder, maar ook een eerder seintje dat door "al voorbij" naar de beslisdag schuift.
14. **Na Houden** op een doorlopend abonnement worden de seintjes voor de *volgende* beslisdatum alvast gepland. Zo blijft het werken als de app een tijd niet opent. De groepering kijkt wel naar de huidige beslisdatum, zoals de opdracht zegt.
15. **Te laat voor deze ronde.** Bij een opzegtermijn die langer is dan het interval (bijv. 2 maanden bij een maandabonnement) schuift de beslisdatum zo veel rondes op als nodig.
16. **Verlopen vaste einddatum.** In Nederland loopt zo'n contract daarna meestal maandelijks door. Het wordt daarom een maandabonnement vanaf de einddatum, met de kaart "loopt nu waarschijnlijk door". De uitzondering is als Houden de beslisdatum al dekte. Zonder deze regel zou het item voor altijd in Nu beslissen blijven staan.
17. **Interval bij een proef.** Een proef bewaart het catalogusinterval (bijv. jaar), zodat de prijs het juiste label krijgt ("daarna € 99 per jaar"). Na afloop geldt de overgangsregel uit de opdracht.
18. **Datum in het verleden bij een proef.** Bij bewaren wordt het een actief abonnement met het interval uit de catalogus, en anders per maand.
19. **Bewerken** wijzigt het anker alleen als je de datum echt verandert. Anders zou een anker op de 31e verloren gaan.
20. **Resterende dagen.** Voor een opgezegd item tellen ze tot `usableUntil`. Bij gestopt staat er niets. Een datum die al voorbij is (kan alleen bij een proef met opzegtermijn) toont "voorbij".
21. **"Ik had al opgezegd"** zet `usableUntil` op het einde van de proef of termijn, zodat "Gestopt op …" een datum heeft.
22. **"Toch niet opgezegd"** op een proef die al voorbij is, maakt er een actief abonnement van vanaf het einde van de proef.
23. **Badge per melding.** De badge wordt per dag berekend met de overgangen die tegen die dag gedraaid zullen hebben. Staat de badge uit, dan wordt hij op 0 gezet.

## Meldingen

24. **Titels.** Een weekdag gebruik ik alleen binnen 6 dagen, anders de datum ("verlengt 14 mrt"). Bij een vaste einddatum: "<naam>: loopt af <dag>".
25. **Prijs na een proef** staat ook in de melding op de beslisdag: "Laatste dag om kosteloos op te zeggen. Daarna € 9,99 per maand."
26. **Gebundelde namen** staan op beslisdatum en dan op naam. Bij meer dan 3 items: de eerste twee plus "en N andere", volgens het voorbeeld in de opdracht.
27. **Houden vanuit een melding** werkt stil op de achtergrond, zonder toast. In de app toont Houden de toast.
28. **De gelukt-vraag** komt pas als de app echt naar de achtergrond is geweest (Safari) of opnieuw is gestart. Zo verschijnt hij niet al terwijl Safari nog opent. Hij komt ook niet als het item intussen niet meer loopt.
29. **Review-verzoek** bij de eerste opzegging ooit, ongeacht de weg: swipe Opgezegd of "Ja, opgezegd".
30. **Opzeglinks.** Een eigen link zonder schema krijgt `https://` ervoor. De DuckDuckGo-zoeklink codeert de spatie als `%20` in plaats van `+`; dat werkt hetzelfde.
31. **De achtergrondtaak** wordt aangevraagd voor 00:05 de volgende dag: bij app-start, bij naar de achtergrond gaan en na elke run.

## Schermen

32. **Datumnotatie.** Ik gebruik vaste Nederlandse tabellen ("do 3 nov", "14 mrt"), want CLDR geeft "nov." met een punt en verschilt per iOS-versie. Voor een datum in een ander jaar komt het jaartal erbij ("vr 10 sep 2027"). De UI-locale staat op `nl_NL`, ook voor datumkiezers.
33. **Bedragen** als "€ 9,99", en hele euro's zonder ",00" ("€ 79"). Het invoerveld accepteert zowel komma als punt.
34. **Lege naam** wordt "Naamloos". Normaal komt dit niet voor, omdat er vanaf stap 1 altijd een naam is.
35. **Live regel.** Bij een opzegtermijn komt er "· opzeggen vóór …" bij. Staan de seintjes uit (maand of week), dan staat er "· geen seintje".
36. **Seintje vooraf.** Zet je de stepper op de standaardwaarde, dan wordt de override weer leeg. Een latere wijziging van de standaard in Instellingen werkt dan gewoon door.
37. **Seintje bij verlenging.** Aan betekent een override `true`. Uit maakt de override weer leeg, want uit is de standaard voor maand en week.
38. **"Anders" bij het interval** kiest standaard Kwartaal, en daarna kun je Week of Vaste einddatum kiezen.
39. **Swipe Opgezegd** staat alleen bij items die lopen (proef of actief). Verwijderen kan bij alle items.
40. **Opgezegd en Gestopt** hebben een eigen kop met het aantal en een pijltje om in en uit te klappen. `Section(isExpanded:)` doet dat alleen in sidebar-lijsten.
41. **De kaart "Meldingen staan uit"** kun je wegvegen of sluiten met een kruisje.
42. **Meldingen in Instellingen.** Is de status nog onbepaald, dan vraagt "Zet aan" meteen toestemming. Anders opent de knop de iOS-instellingen.
43. **De toevoeg-sheet** heeft een knop Annuleer. Het bewerkformulier is dezelfde view als stap 2 en opent als sheet vanuit het detail.
44. **Eigen items** (zonder catalogus) krijgen de categorie "overig" met een grijs icoon.
45. **Categoriekleuren** zijn systeemkleuren:
    - streaming rood, muziek groen, kranten blauw;
    - maaltijdboxen oranje, sport paars, opslag teal;
    - software indigo, luisterboeken bruin.
46. **CSV.**
    - Kolomnamen in het Nederlands.
    - Bedragen met een komma, tijdstempels in ISO 8601.
    - Regeleinde CRLF.
    - Velden met `;`, `"` of een regeleinde staan tussen aanhalingstekens.
47. **Widget.**
    - De eerste entry geldt vanaf nu, de volgende zes om 00:00.
    - De widget leest de store via een eigen `ModelContext` en past de overgangen vooruit toe.
    - Zonder item opent een tik `opzegwekker://overview`.
48. **Debug-seed** (alleen DEBUG). Hij laadt via het launch-argument `-OpzegwekkerSeed` of via de knop "Testdata laden" in Instellingen, maar alleen als de app leeg is.

## Catalogus

49. Er staan 44 diensten in, verdeeld over de acht gevraagde categorieën. `trialDays` en `cancelURL` staan overal op `null`.
50. `appleBilling`, `defaultKind`, `defaultInterval` en `domains` heb ik ingevuld op basis van algemene kennis. Ze staan ook in `CATALOG_TODO.md` om na te lopen.
51. De 8 populaire diensten zijn Netflix, Videoland, Disney+, HBO Max, Spotify, NRC, HelloFresh en Storytel.
