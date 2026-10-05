# App Review notes

Paste the text below into App Store Connect → App Review Information → Notes. It is written in English because reviewers usually are not Dutch speakers. It stays well under the 4,000-character limit.

---

Opzegwekker ("cancel alarm") reminds you before a free trial ends or a subscription renews, so you can cancel in time. The app is free, has no account or login, makes no network requests, and keeps all data on the device. The interface is Dutch only; we publish it in the Netherlands (and Belgium).

NO LOGIN NEEDED. The app opens on an empty screen with suggestions.

QUICK TEST (about 3 minutes)
1. Tap "Iets anders" (something else), type "Test", then tap "‘Test’ toevoegen" (add).
2. Under "Eindigt over" (ends in), tap "Datum…" and pick tomorrow. Tap "Bewaar" (save).
3. Allow notifications when iOS asks.
4. Tap the gear icon (top right). Under "Tijdstip seintjes" (reminder time), choose a time 2 minutes from now. Tap "Klaar" (done).
5. Lock the device. A reminder arrives at that time with three actions: "Opzeggen" (cancel), "Houden" (keep) and "Morgen opnieuw" (remind me tomorrow).
   - "Houden" and "Morgen opnieuw" work without opening the app.
   - "Opzeggen" opens the app on the item and opens the cancellation page in Safari. Without a known cancellation link, that is a DuckDuckGo search for "<name> opzeggen".
6. Back in the app you are asked whether cancelling succeeded ("Is opzeggen … gelukt?").

WHY TIME-SENSITIVE NOTIFICATIONS
Only one reminder per item uses the time-sensitive level: the one on the last day you can still cancel without being charged. All earlier reminders use the normal level. The app sends no marketing or promotional notifications.

WHY BACKGROUND FETCH
One BGAppRefreshTask per day, shortly after midnight. It updates the day-based state (for example, a trial that ended becomes an active subscription) and reschedules the local notifications. It makes no network requests.

OTHER NOTES
- Swipe right on a row for "Opgezegd" (cancelled); swipe left to delete, with undo.
- A small home screen widget shows the next decision.
- "Betaald via Apple?" on the detail screen opens Apple's subscription management page for services that can be billed through Apple.
- Service names in the list are used only so people can recognise their own subscriptions. The app shows no brand logos; each item gets a letter on a category colour.
- The app asks for an App Store rating once, after the user's first cancellation, through the standard requestReview API.
- Privacy: no data is collected. PrivacyInfo.xcprivacy declares UserDefaults (reason CA92.1) and nothing else.
- Export compliance: the app uses no encryption beyond what iOS provides (ITSAppUsesNonExemptEncryption = NO).
