# Catalogus nalopen

`Catalog/services.json` bevat 44 diensten. `trialDays` en `cancelURL` staan bewust overal op `null`; die vul jij in.

Per dienst na te lopen:

- **trialDays**: duur van de proefperiode in dagen, of `null` als er geen standaardproef is. Een waarde anders dan 7, 14 of 30 verschijnt in het formulier als gekozen datum.
- **cancelURL**: directe link naar de opzegpagina. Bij `null` toont de app “Zoek opzegpagina” (DuckDuckGo).
- **appleBilling**: `true` als je de dienst ook via een Apple-abonnement kunt betalen. Ik heb dit op basis van algemene kennis ingevuld; graag controleren.
- **defaultKind / defaultInterval**: begint de dienst meestal met een proef, en hoe vaak wordt er betaald? Ook ingevuld op basis van algemene kennis.
- **domains**: alleen informatief; de app gebruikt ze niet en haalt niets op.

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
