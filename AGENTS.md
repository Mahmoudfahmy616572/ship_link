# ShipLink Project Guide

## Build & Run

```bash
# User app
flutter run --flavor user
flutter build apk --debug --flavor user
flutter build apk --release --flavor user

# Driver app
flutter run --flavor driver
flutter build apk --debug --flavor driver
flutter build apk --release --flavor driver
```

## Key Architecture

- **State**: Cubits (no Provider/Bloc where avoidable)
- **Routing**: GoRouter with `shellRoute` for bottom nav
- **Localization**: `easy_localization` with `context.t.tr('key')`
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
