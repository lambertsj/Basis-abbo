# Catalogus nalopen

`Catalog/services.json` bevat 73 diensten. `trialDays` en `cancelURL` staan bewust overal op `null`; die vul jij in.

Per dienst na te lopen:

- **trialDays**: duur van de proefperiode in dagen, of `null` als er geen standaardproef is. Een waarde anders dan 7, 14 of 30 verschijnt in het formulier als gekozen datum.
- **cancelURL**: directe link naar de opzegpagina. Bij `null` toont de app “Zoek opzegpagina” (DuckDuckGo).
- **appleBilling**: `true` als je de dienst ook via een Apple-abonnement kunt betalen. Ik heb dit op basis van algemene kennis ingevuld; graag controleren.
- **defaultKind / defaultInterval**: begint de dienst meestal met een proef, en hoe vaak wordt er betaald? Ook ingevuld op basis van algemene kennis.
- **domains**: alleen informatief; de app gebruikt ze niet en haalt niets op.

Bij internet en tv, mobiel en energie staat het standaardinterval meestal op `fixedEnd` (contract met einddatum); na de einddatum loopt het in de app maandelijks door. Verzekeringen staan op `year`. Een zorgverzekering kun je alleen per 1 januari overzetten; de gebruiker kiest zelf de datum.

Populair (`popular: true`, precies 8, de chips in de lege staat): Netflix, Videoland, Disney+, HBO Max, Spotify, NRC, HelloFresh, Storytel.

## Streaming

- [ ] **Netflix** (`netflix`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Videoland** (`videoland`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Disney+** (`disney-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **HBO Max** (`hbo-max`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Amazon Prime Video** (`prime-video`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Apple TV+** (`apple-tv-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **NPO Plus** (`npo-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Viaplay** (`viaplay`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **SkyShowtime** (`skyshowtime`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **YouTube Premium** (`youtube-premium`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`

## Muziek

- [ ] **Spotify** (`spotify`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Apple Music** (`apple-music`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Deezer** (`deezer`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **TIDAL** (`tidal`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Amazon Music Unlimited** (`amazon-music`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`

## Kranten en tijdschriften

- [ ] **NRC** (`nrc`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **de Volkskrant** (`volkskrant`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **De Telegraaf** (`telegraaf`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **AD** (`ad`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Trouw** (`trouw`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Het Parool** (`parool`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Het Financieele Dagblad** (`fd`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Readly** (`readly`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`

## Maaltijdboxen

- [ ] **HelloFresh** (`hellofresh`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `week`
- [ ] **Marley Spoon** (`marley-spoon`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `week`
- [ ] **Ekomenu** (`ekomenu`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `week`

## Sportscholen

- [ ] **Basic-Fit** (`basic-fit`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **SportCity** (`sportcity`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Fit For Free** (`fit-for-free`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Anytime Fitness** (`anytime-fitness`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Urban Sports Club** (`urban-sports-club`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`

## Opslag

- [ ] **iCloud+** (`icloud-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Google One** (`google-one`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Dropbox** (`dropbox`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`

## Software

- [ ] **Microsoft 365** (`microsoft-365`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `year`
- [ ] **Adobe Creative Cloud** (`adobe-creative-cloud`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **ChatGPT Plus** (`chatgpt-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Duolingo Super** (`duolingo`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `year`
- [ ] **1Password** (`1password`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `trial`, defaultInterval `year`
- [ ] **NordVPN** (`nordvpn`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `true`)
    - [ ] defaultKind `subscription`, defaultInterval `year`

## Luisterboeken

- [ ] **Storytel** (`storytel`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **BookBeat** (`bookbeat`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Audible** (`audible`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`
- [ ] **Kobo Plus** (`kobo-plus`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `trial`, defaultInterval `month`

## Internet en tv

- [ ] **Ziggo** (`ziggo`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **KPN Internet en tv** (`kpn-thuis`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Odido Thuis** (`odido-thuis`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **DELTA Fiber** (`delta`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Caiway** (`caiway`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`

## Mobiel

- [ ] **KPN Mobiel** (`kpn-mobiel`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Vodafone** (`vodafone`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Odido Mobiel** (`odido-mobiel`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Simyo** (`simyo`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Lebara** (`lebara`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Ben** (`ben`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`
- [ ] **Youfone** (`youfone`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `month`

## Energie

- [ ] **Vattenfall** (`vattenfall`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Eneco** (`eneco`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Essent** (`essent`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Greenchoice** (`greenchoice`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Budget Energie** (`budget-energie`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Pure Energie** (`pure-energie`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Energiedirect.nl** (`energiedirect`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`
- [ ] **Vandebron** (`vandebron`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `fixedEnd`

## Verzekeringen

- [ ] **Zilveren Kruis** (`zilveren-kruis`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **CZ** (`cz`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **VGZ** (`vgz`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **Menzis** (`menzis`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **Centraal Beheer** (`centraal-beheer`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **Interpolis** (`interpolis`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **ANWB Verzekeringen** (`anwb-verzekeringen`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **FBTO** (`fbto`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
- [ ] **Ohra** (`ohra`)
    - [ ] trialDays (nu `null`)
    - [ ] cancelURL (nu `null`)
    - [ ] appleBilling (nu `false`)
    - [ ] defaultKind `subscription`, defaultInterval `year`
