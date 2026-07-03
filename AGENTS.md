# ShipLink Project Guide

## Build & Run

```bash
# User app
flutter run --flavor user --target lib/main_user.dart
flutter build apk --debug --flavor user --target lib/main_user.dart
flutter build apk --release --flavor user --target lib/main_user.dart --split-per-abi

# Driver app
flutter run --flavor driver --target lib/main_driver.dart
flutter build apk --debug --flavor driver --target lib/main_driver.dart
flutter build apk --release --flavor driver --target lib/main_driver.dart --split-per-abi

# Web app (independent – no existing files modified)
flutter run -d chrome --target lib/main_web.dart
flutter build web --target lib/main_web.dart --release
flutter build web --target lib/main_web.dart --profile
```

## Key Architecture

- **State**: Cubits (no Provider/Bloc where avoidable); Web uses ChangeNotifier+Provider (avoids importing packages with flutter_secure_storage)
- **Routing**: GoRouter with `shellRoute` for bottom nav; Web uses `onGenerateRoute` + `PageRouteBuilder` fade transitions
- **Localization**: `easy_localization` with `context.t.tr('key')`; Web uses custom `AppLocalizations.delegate` + `context.t` extension (falls back to English if delegate not yet loaded)
- **Backend**: Supabase (auth + postgres + functions)
- **Notifications**: `flutter_local_notifications` + polling every 10s on `notifications` table; FCM via Edge Function `send_push` (fallback: `FcmPushService` with service account)

## Important Rules

- **Never** reintroduce `flutter_staggered_grid_view`
- **Never** use `BlocConsumer` or `context.watch` for `GetFromCartCubit` / `FavouriteCubit` — use `context.select` or `BlocBuilder` with `buildWhen`
- **Both** flavors (`user`, `driver`) must build before committing
- Driver registration inserts into both `drivers` + `profiles` tables

## Database Migrations

All-in-one: `complete_supabase_schema.sql` — run in Supabase SQL Editor.

## When FCM Background Notifications Don't Work

1. Edge Function `send_push` not deployed → `npx supabase functions deploy send_push --project-ref <ref>`
2. Missing secrets → `npx supabase secrets set FIREBASE_SERVICE_ACCOUNT` (paste JSON content)
3. Firebase `FIS_AUTH_ERROR` on emulator → add SHA-1 debug fingerprint in Firebase Console, or test on real device

## Common Issues

- `PathNotFoundException: app.dill` → delete `%LOCALAPPDATA%\Temp\flutter_tools*`
- `Gradle AAR metadata` → ensure `coreLibraryDesugaringEnabled` + `desugar_jdk_libs:2.1.5` in `android/app/build.gradle`

## Web-Specific Known Issues

### White screen / "No client connected" on first run
If the web app shows a white screen and Chrome disconnects:
1. Close all Chrome tabs (including background processes from taskbar)
2. Run `flutter clean && flutter build web --target lib/main_web.dart --release`
3. Serve the built files directly (bypasses debug WebSocket):
   ```powershell
   cd build\web
   python -m http.server 8080
   ```
   Then open `http://localhost:8080` in Chrome.
4. If the page loads successfully with the HTTP server, the issue is the Flutter debug WebSocket connection (port conflict / firewall). Try `flutter run -d chrome --target lib/main_web.dart --web-port 0` to use a random port.

### Passkeys Web SDK stub
`passkeys_web` package checks `window['PasskeyAuthenticator']` on init and calls `window.close()` if missing. Fixed by defining a stub in `web/index.html` with all 7 interop methods (init, register, login, cancel, availability checks). Stubs return empty/fallback values – passkey operations should never be called since the app only uses email/password + Google OAuth.

### Localization null crash (FIXED)
Extension `AppLocalizationsX.t` on `BuildContext` used `!` on `Localizations.of()`. If called before the delegate finishes loading, it throws a null error. Fixed by returning `AppLocalizations(const Locale('en'))` as fallback.

### Web-specific files (new, do not modify existing)
- `lib/main_web.dart` – independent entry point (no flutter_secure_storage, no sqflite)
- `lib/services/auth_service_web.dart` – ChangeNotifier-based auth (avoids auth_cubit.dart import chain)
- `lib/services/web_cache_service.dart` – SharedPreferences-only cache
- `lib/views/web/` – all web screens
- `lib/routs_web.dart` – web routing with fade transitions
