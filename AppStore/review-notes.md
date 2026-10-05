# App Review notes

Dit staat in App Store Connect onder App Review Information (contact: Jeroen Lamberts, +31 6 51 89 12 91). De notities zijn in het Engels omdat reviewers meestal geen Nederlands lezen. Ze blijven ruim onder de limiet van 4.000 tekens (nu 3.665).

Wijzig je de app, werk dan deze tekst bij en zet hem opnieuw in App Store Connect.

---

PURPOSE
Opzegwekker ("cancel alarm") helps people avoid paying for things they meant to cancel. Many free trials and subscriptions renew automatically, and people forget the cancellation deadline. The user adds a trial or subscription; the app works out the last day on which cancelling is still free (taking any notice period into account) and sends a local reminder in time. From the reminder the user can cancel, keep it or postpone the decision, without opening the app first.

The app is free, has no account or login, contains no ads or in-app purchases, collects no data and makes no network requests. Everything is stored on the device. The interface is Dutch only; we publish in the Netherlands and Belgium.

NO LOGIN OR DEMO ACCOUNT IS NEEDED. The app opens on an empty screen with suggestions.

MAIN FEATURES
- Overview: "Nu beslissen" (decide now), "Binnenkort" (soon) and "Loopt door" (continues) groups, plus an estimate of the monthly total.
- Add a service from a built-in list of common Dutch services, or type any name ("Iets anders"). Trials take an end date; subscriptions take a renewal date, interval and optional notice period.
- Reminders: for a trial, 2 days before and on the last day; for a yearly subscription, 2 weeks before. Lead times can be changed in Settings.
- Notification actions: "Opzeggen" (cancel), "Houden" (keep), "Morgen opnieuw" (remind me tomorrow).
- Small home screen widget with the next decision.
- Export all items as CSV (Settings).

QUICK TEST (about 3 minutes)
1. Tap "Voeg toe", then "Iets anders", type "Test" and tap "'Test' toevoegen".
2. Under "Eindigt over" (ends in), tap "Datum..." and pick tomorrow. Tap "Bewaar" (save).
3. Allow notifications when iOS asks.
4. Tap the gear icon (top right). Under "Tijdstip seintjes" (reminder time) choose a time 2 minutes from now. Tap "Klaar" (done).
5. Lock the device. At that time a reminder arrives with the three actions above.
   - "Houden" and "Morgen opnieuw" work without opening the app.
   - "Opzeggen" opens the app on the item and opens the cancellation page in Safari. If no cancellation link is known, it opens a web search for "<name> opzeggen".
6. Back in the app you are asked whether cancelling succeeded ("Is opzeggen ... gelukt?").
Also: swipe right on a row for "Opgezegd" (cancelled); swipe left to delete, with undo. Add the widget via the home screen: long-press, "+", Opzegwekker.

WHY TIME-SENSITIVE NOTIFICATIONS
Only one reminder per item uses the time-sensitive level: the one on the last day the user can still cancel without being charged. All earlier reminders use the normal level. The app sends no marketing or promotional notifications.

WHY BACKGROUND REFRESH
One BGAppRefreshTask per day, shortly after midnight. It updates day-based state (for example, a trial that has ended becomes an active subscription) and reschedules the local notifications. It makes no network requests.

OTHER NOTES
- "Betaald via Apple?" on the detail screen opens Apple's subscription management page for services that can be billed through Apple.
- Service names appear only so people recognise their own subscriptions. The app shows no brand logos; each item gets a letter on a category colour. No brand names are used in our metadata.
- The app asks for an App Store rating once, after the user's first cancellation, via the standard requestReview API.
- Privacy: no data is collected. PrivacyInfo.xcprivacy declares UserDefaults (reason CA92.1) and nothing else.
- Export compliance: no encryption beyond what iOS provides (ITSAppUsesNonExemptEncryption = NO).
- The source code is public.

Questions? Please call or email; we respond quickly.
