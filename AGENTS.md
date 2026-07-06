# ShipLink Project Guide

## Build & Run

```bash
# User app
flutter run --flavor user --target lib/user/main_user.dart
flutter build apk --debug --flavor user --target lib/user/main_user.dart
flutter build apk --release --flavor user --target lib/user/main_user.dart --split-per-abi

# Driver app
flutter run --flavor driver --target lib/driver/main_driver.dart
flutter build apk --debug --flavor driver --target lib/driver/main_driver.dart
flutter build apk --release --flavor driver --target lib/driver/main_driver.dart --split-per-abi

# Web app
flutter run -d chrome --target lib/web/main_web.dart
flutter build web --target lib/web/main_web.dart --release
flutter build web --target lib/web/main_web.dart --profile
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

## Paymob Edge Functions

### Deploy callback with `--no-verify-jwt` (CRITICAL)
The `paymob-callback` function is called by Paymod via browser redirect — no JWT token is available. **Every deployment** must use `--no-verify-jwt`:
```bash
npx supabase functions deploy paymob-callback --project-ref aqxiziqybgtvrdfhmmoc --no-verify-jwt
```
If you forget this flag, the Supabase gateway returns `401` and the function never executes (no "Execute" logs, only "shutdown" events).

### All Paymob functions
```bash
# Deploy all at once:
npx supabase functions deploy paymob-add-card --project-ref aqxiziqybgtvrdfhmmoc
npx supabase functions deploy paymob-checkout --project-ref aqxiziqybgtvrdfhmmoc
npx supabase functions deploy paymob-saved-card-checkout --project-ref aqxiziqybgtvrdfhmmoc
npx supabase functions deploy paymob-callback --project-ref aqxiziqybgtvrdfhmmoc --no-verify-jwt
```

### Iframe callback parameter
All Paymob iframe URLs include a `callback` parameter pointing to the Supabase edge function. If the Paymob dashboard already has a callback URL configured, this overrides it with the correct one.

## Android SDK Versions

- **Gradle**: 9.6.1 (`android/gradle/wrapper/gradle-wrapper.properties`)
- **AGP**: 9.2.0 (`android/settings.gradle`)
- **Kotlin**: 2.4.0 (`android/settings.gradle`)
- **NDK**: 28.2.13676358 (`android/app/build.gradle`)
- **Google Services**: 4.5.0 (`android/settings.gradle`)
- **SDK Build Tools**: 36.0.0+ (installed via Android SDK Manager)

## Common Issues

- `PathNotFoundException: app.dill` → delete `%LOCALAPPDATA%\Temp\flutter_tools*`
- `Gradle AAR metadata` → ensure `coreLibraryDesugaringEnabled` + `desugar_jdk_libs:2.1.5` in `android/app/build.gradle`
- `flutter_inappwebview_android` AGP 9 proguard error → `android.r8.proguardAndroidTxt.disallowed=false` in `android/gradle.properties`
### Patched Third-Party Plugins
- `workmanager_android` patched locally at `patched/workmanager_android` — removed `apply plugin: 'kotlin-android'` from `android/build.gradle`. Used via `dependency_overrides` in `pubspec.yaml`. If Flutter/AGP upgrade breaks it, re-copy from pub cache and re-apply the same fix.
- Third-party KGP plugin warning → 9 plugins → 3 remaining. Fixed: device_info_plus, package_info_plus, shared_preferences_android, webview_flutter_android (via dependency_overrides), rive_common (via rive 0.14.9), flutter_credit_card (removed, unused), workmanager_android (patched locally at `patched/workmanager_android` — removed `apply plugin: 'kotlin-android'` from build.gradle, used via `dependency_overrides` with path). Remaining 3 (passkeys_android, rive_native, ua_client_hints — all transitive, maintainers actively working) — not blocking yet
- Rive 0.14.x migration: requires `await RiveNative.init()` in `main()`, `File.asset()` + `RiveWidgetController` replaces `RiveAnimation.asset()` + `StateMachineController`, `BooleanInput` replaces `SMIBool`, use `controller.stateMachine?.boolean('name')` instead of `controller.findSMI("name")`, use `input.value = true/false` instead of `input.change(true/false)`, `RiveWidget(controller: controller)` replaces `RiveAnimation.asset(onInit: ...)`

## Web-Specific Known Issues

### White screen / "No client connected" on first run
If the web app shows a white screen and Chrome disconnects:
1. Close all Chrome tabs (including background processes from taskbar)
2. Run `flutter clean && flutter build web --target lib/web/main_web.dart --release`
3. Serve the built files directly (bypasses debug WebSocket):
   ```powershell
   cd build\web
   python -m http.server 8080
   ```
   Then open `http://localhost:8080` in Chrome.
4. If the page loads successfully with the HTTP server, the issue is the Flutter debug WebSocket connection (port conflict / firewall). Try `flutter run -d chrome --target lib/web/main_web.dart --web-port 0` to use a random port.

### Passkeys Web SDK stub
`passkeys_web` package checks `window['PasskeyAuthenticator']` on init and calls `window.close()` if missing. Fixed by defining a stub in `web/index.html` with all 7 interop methods (init, register, login, cancel, availability checks). Stubs return empty/fallback values – passkey operations should never be called since the app only uses email/password + Google OAuth.

### Localization null crash (FIXED)
Extension `AppLocalizationsX.t` on `BuildContext` used `!` on `Localizations.of()`. If called before the delegate finishes loading, it throws a null error. Fixed by returning `AppLocalizations(const Locale('en'))` as fallback.

### Web-specific files
- `lib/web/main_web.dart` – independent entry point (no flutter_secure_storage, no sqflite)
- `lib/web/presentation/services/auth_service_web.dart` – ChangeNotifier-based auth (avoids auth_cubit.dart import chain)
- `lib/web/presentation/services/web_cache_service.dart` – SharedPreferences-only cache
- `lib/web/presentation/screens/` – all web screens
- `lib/web/routs_web.dart` – web routing with fade transitions
