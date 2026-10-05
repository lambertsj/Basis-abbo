# App Store-teksten

Klaar om in App Store Connect te plakken. De lengtes zijn gecontroleerd tegen de limieten van Apple.

Lees het wel zelf door en pas het aan je eigen toon aan. Een tekst die naar jou klinkt, valt minder op als generiek dan een tekst die je ongelezen overneemt.

Merknamen (Netflix, Ziggo, …) staan bewust niet in de naam, ondertitel, zoekwoorden of beschrijving. Apple wijst metadata met namen van andere merken af (richtlijn 2.3.7 en 5.2).

## Naam (11/30)
Opzegwekker

## Ondertitel (30/30)
Seintje vóór je proef verlengt

## Promotietekst (147/170)
Deze tekst kun je later aanpassen zonder nieuwe review.

Voeg je proefperiodes en abonnementen toe en krijg op tijd een seintje. Vanuit de melding kun je meteen opzeggen, houden of het een dag uitstellen.

## Zoekwoorden (97/100)
Gescheiden door komma's, zonder spaties. Laat de app-naam weg: die telt al mee.

```
proefperiode,abonnement,opzeggen,seintje,verlengen,contract,opzegtermijn,streaming,energie,mobiel
```

## Beschrijving (1455/4000)

Gratis proefperiode afgesloten en vergeten op te zeggen? Opzegwekker geeft je een seintje voordat je moet betalen.

HOE HET WERKT
Kies een dienst of typ zelf een naam, en tik op Bewaar. De app rekent uit wanneer je uiterlijk moet beslissen, met je opzegtermijn erbij, en stuurt op tijd een seintje. Bij een proef twee dagen van tevoren en op de laatste dag zelf. Bij een jaarabonnement twee weken van tevoren.

IN DE MELDING ZELF
• Opzeggen: opent de opzegpagina, of zoekt die voor je op.
• Houden: je hoort er pas weer van bij de volgende verlenging.
• Morgen opnieuw: nog even geen tijd.
Kom je terug na het opzeggen, dan vraagt de app of het gelukt is.

GEMAAKT VOOR NEDERLAND
Opzegwekker kent veel diensten die je hier gebruikt: streaming, muziek, kranten, maaltijdboxen, sportscholen, internet en tv, mobiel, energie en verzekeringen. Loopt een contract met vaste looptijd af, dan houdt de app er rekening mee dat het daarna meestal maandelijks doorloopt, en vraagt of dat klopt.

OVERZICHT
• Bovenaan wat je nu moet beslissen, daaronder wat binnenkort komt.
• Een schatting van wat je per maand betaalt.
• Een widget voor je beginscherm.
• Exporteren als CSV, voor Excel of Numbers.

ZONDER GEDOE
Geen account, geen reclame, geen tracking en geen abonnement op de app zelf. Alles blijft op je iPhone; de app maakt geen verbinding met internet. De broncode is openbaar.

Opzegwekker is een BasisApp: een eenvoudige, gratis app die één ding goed doet.

## Nieuw in deze versie
Eerste versie.

## Overige velden in App Store Connect

| Veld | Waarde |
| --- | --- |
| Primaire categorie | Productiviteit (komt overeen met `LSApplicationCategoryType` in het project) |
| Secundaire categorie | Financiën |
| Prijs | Gratis |
| Beschikbaarheid | Nederland, België (de app is alleen in het Nederlands) |
| Leeftijdsclassificatie | 4+ (vragenlijst: overal "Geen"; onbeperkte webtoegang: nee, links openen in Safari) |
| Privacy-labels | "Gegevens worden niet verzameld" |
| Privacybeleid-URL | de pagina met `privacybeleid.md`, bijv. `https://basisapps.nl/opzegwekker/privacy` |
| Support-URL | `https://basisapps.nl` (moet live zijn) |
| Copyright | 2026 [naam] |
| Inlog voor review | Niet nodig (zie `review-notes.md`) |
| Exportcontrole | Geen versleuteling buiten iOS (`ITSAppUsesNonExemptEncryption = NO` staat al in het project) |

## Screenshots

- **Echte schermafbeeldingen uit de app** (richtlijn 2.3.3). De HTML-nabootsingen uit de ontwerpfase mogen hiervoor niet gebruikt worden.
- Formaat: 6,9-inch iPhone (1320 × 2868 of 1290 × 2796). Kleinere formaten genereert App Store Connect zelf.
- Gebruik de debug-seed (launch-argument `-OpzegwekkerSeed`) voor een gevuld overzicht. Of beter: voer eigen namen in, dan staan er geen merknamen groot in beeld.
- Voorstel voor 4 schermen:
    1. overzicht met Nu beslissen;
    2. een melding met de acties Opzeggen, Houden en Morgen opnieuw;
    3. het detail "Beslis vóór …";
    4. de widget op het beginscherm.
- Een korte regel tekst boven elk screenshot mag, als die beschrijft wat je ziet.
