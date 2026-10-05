# Testlijst eerste build

De iOS-code is nog nooit gecompileerd, dus deze lijst is de eerste echte controle. Test op een **echt toestel**, want meldingen, de widget en de achtergrondtaak werken in de simulator maar half. Test ook één keer op een **iPad**: Apple controleert iPhone-apps daar in compatibiliteitsmodus.

Tip: het tijdstip van de seintjes stel je in via Instellingen → Tijdstip seintjes. Zet het een paar minuten vooruit, dan hoef je niet te wachten.

## 1. Bouwen en starten
- [ ] Project opent in Xcode, team ingesteld bij app en widget.
- [ ] Bouwt zonder fouten en zonder warnings (Debug én Release).
- [ ] Tests groen met ⌘U.
- [ ] Eerste start: lege staat met de vraag en 8 chips, geen crash.
- [ ] Release-build: geen knop "Testdata laden" in Instellingen.

## 2. Toevoegen
- [ ] Lege app: chip → formulier al ingevuld → Bewaar (2 tikken).
- [ ] Gevuld overzicht: Voeg toe → dienst → Bewaar (3 tikken).
- [ ] Zoekveld heeft meteen focus en het toetsenbord staat open.
- [ ] Zoeken zonder hoofdletters en accenten werkt ("cafe" vindt "Café").
- [ ] Return kiest de exacte match, anders "‘…’ toevoegen".
- [ ] Toast na het eerste item: "Toegevoegd · seintje …".
- [ ] Halve seconde later: de iOS-vraag om meldingen toe te staan.
- [ ] Datum in het verleden: waarschuwing, en na bewaren een actief abonnement.
- [ ] Prijs met komma en met punt ("9,99" en "9.99").
- [ ] Vaste einddatum (bijv. Ziggo): "Loopt tot", seintje 30 dagen vooraf.

## 3. Overzicht
- [ ] Groepen in de juiste volgorde; Opgezegd en Gestopt zijn ingeklapt.
- [ ] Maandtotaal klopt; tik toont "Berekend op basis van …".
- [ ] Swipe rechts → "Opgezegd" → sheet met datum → Bevestig.
- [ ] Swipe links → direct weg → toast → Ongedaan maken zet het item volledig terug.
- [ ] Rood, oranje en grijs bij de resterende dagen, altijd met tekst erbij.

## 4. Detail
- [ ] Opzeggen opent Safari; zonder link: DuckDuckGo-zoekopdracht.
- [ ] Na terugkeer binnen 30 minuten: "Is opzeggen van … gelukt?".
- [ ] "Ja, opgezegd" → status opgezegd; bij de eerste keer verschijnt de iOS-beoordelingsvraag.
- [ ] Houden → korte melding met de volgende datum.
- [ ] Tik op een inforegel → bewerkformulier met dat veld in focus.
- [ ] Opgezegd item: kop "Loopt af op …" en alleen "Toch niet opgezegd".

## 5. Meldingen
- [ ] Melding komt op het ingestelde tijdstip, ook als de app dicht is.
- [ ] Houden en Morgen opnieuw vanuit de melding openen de app **niet**, en het item verandert wel.
- [ ] Opzeggen vanuit de melding opent het detail én Safari.
- [ ] Tik op de melding opent het detail; een gebundelde melding opent het overzicht.
- [ ] Twee items op dezelfde dag geven één melding, "Vandaag 2 beslissingen".
- [ ] Melding op de laatste dag is time-sensitive (komt door Focus heen als dat is toegestaan).
- [ ] Melding terwijl de app open is, verschijnt als banner.
- [ ] App-badge toont het aantal in Nu beslissen; staat op 0 als de toggle uit staat.
- [ ] Meldingen geweigerd: kaart bovenaan, wegvegen werkt, komt terug na de volgende toevoeging.

## 6. Widget
- [ ] Widget toont het eerstvolgende item, of "Niets om over te beslissen".
- [ ] Tik op de widget opent het juiste detail.
- [ ] Widget werkt bij na een wijziging in de app.

## 7. Instellingen
- [ ] Tijdstip en standaard vooraf aanpassen plant de seintjes opnieuw.
- [ ] CSV-export opent goed in Excel (Nederlands): kolommen, € met komma, é en ë.
- [ ] Links naar basisapps.nl en de broncode werken.
- [ ] Alles wissen: één bevestiging, daarna een lege app.

## 8. Toegankelijkheid en uiterlijk
- [ ] Grootste tekstgrootte (Toegankelijkheid): geen afgekapte tekst, rijen stapelen netjes.
- [ ] VoiceOver leest een rij als "Videoland, proef eindigt donderdag 3 november, nog 5 dagen".
- [ ] VoiceOver-acties Opgezegd en Verwijder op een rij.
- [ ] Donkere modus: papier en inkt kloppen, geen onleesbare tekst.
- [ ] App-icoon op het beginscherm, in Instellingen en in Spotlight.

## 9. Randgevallen
- [ ] Proef die vandaag eindigt en waarvan het tijdstip al voorbij is: geen melding, wel rood bovenaan.
- [ ] Na de einddatum van een proef: kaart "loopt nu waarschijnlijk door".
- [ ] Tijdzone wijzigen in iOS: seintjes blijven op hetzelfde kloktijdstip.
- [ ] App een paar dagen niet openen: achtergrondtaak heeft de seintjes bijgewerkt.
