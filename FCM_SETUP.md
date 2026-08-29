# FCM / Push Notifications Setup (BUG-003)

- **Severity:** P3 (Low) — external
- **Status in this release:** NOT applied (config + feature work outside this repo's shipped scope)
- **Blocking?** No. In-app `notifications` table works; only remote push is pending.

## Current state (codebase audit)

| Item | Status |
|------|--------|
| `android/app/google-services.json` | present (Android FCM config) |
| `lib/core/firebase_options.dart` | present (Firebase init config) |
| `ios/Runner/GoogleService-Info.plist` | **MISSING** — iOS FCM not configured |
| FCM handler code (`FirebaseMessaging` calls in `lib/`) | **none** — token not fetched/stored, no foreground/background handlers |
| `fcm_token` column on `profiles` / `drivers` | **missing** |
| Supabase → FCM send path | not wired |

Root cause of `FIS_AUTH_ERROR` on emulator: missing SHA-1 fingerprint and/or no Play Services. On a
physical device this is fixed by registering the signing key's SHA-1 in Firebase.

## Steps to complete

### A. Firebase console (project config)
1. **Android SHA-1:** Project Settings → Your apps → Android → add the **SHA-1** (and SHA-256) of your
   signing key. Fixes `FIS_AUTH_ERROR` on real devices / Play-Services emulators.
2. **Add iOS app** to the same Firebase project with the bundle id from
   `ios/Runner/Info.plist` (`CFBundleIdentifier`). Download `GoogleService-Info.plist` →
   `ios/Runner/GoogleService-Info.plist`; add it to the Runner target in Xcode.
3. **Xcode capabilities:** enable **Push Notifications** and
   **Background Modes → Remote notifications** for Runner.
4. **APNs key:** Project Settings → Cloud Messaging → iOS app → upload your APNs auth key.
5. (Optional) Re-run `flutterfire configure` to regenerate `firebase_options.dart` if unsure it matches.

### B. Code wiring (in repo)
6. Migration: add `fcm_token TEXT` (and `fcm_token_updated_at TIMESTAMPTZ`) to `profiles`
   (and `drivers` if drivers push). Place under `supabase/migrations/`.
7. On login / app start: `await FirebaseMessaging.instance.requestPermission();`
   store `FirebaseMessaging.instance.getToken()` on the user's row; refresh on `onTokenRefresh`.
8. Handlers: `FirebaseMessaging.onMessage` (foreground), `onMessageOpenedApp`, and a top-level
   `firebaseMessagingBackgroundHandler` for `onBackgroundMessage`.
9. Server: Supabase Edge Function (or DB trigger) that reads recipient `fcm_token` and sends via
   FCM HTTP v1 when a row is inserted into `notifications`; set `push_sent = true`.

### C. Verify
10. Run on a **physical device** (not emulator): confirm `getToken()` is non-null (no `FIS_AUTH_ERROR`),
    then send a test push and confirm delivery.

## Note
This is external config + a feature addition; it is intentionally out of the RC. The released app is
fully functional for in-app notifications; remote FCM push is the remaining follow-up.
