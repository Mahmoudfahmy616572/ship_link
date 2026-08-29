# SHIPLINK — REAL DEVICE QA FINAL REPORT

> Mode: VALIDATION / QA ONLY. No code was modified during this task. All device-dependent
> checks are reported as `NOT TESTED — NO PHYSICAL DEVICE AVAILABLE` because this environment
> has no Android / Huawei / iOS device and no browser with a live GPS source.

## 1. Test Environment

- Host OS: Windows 11 (PowerShell 5.1)
- Flutter: 3.44.2 (stable) — Framework c9a6c48423, Engine 04efd7c093, Dart 3.12.2, DevTools 2.57.0
- Android SDK / Gradle present (driver & user APKs built locally). AGP 9.2.0, Gradle 9.6.1, Kotlin 2.4.0
- No macOS host → iOS build NOT performed
- No physical phone → all runtime/field tests NOT performed
- No live Supabase/MapTiler/GraphHopper/Firebase credentials verified against a running backend in this env
  (config defaults exist in `lib/core/config.dart`; real keys live in `.env`, gitignored)

## 2. Release Candidate Baseline

- Git branch: `main`
- Git HEAD: `7dc8914` ("chore: add deploy-user workflow for /ship_link/")
- Working tree: **dirty** — 31 modified + 2 deleted tracked files, plus untracked new modules
  (`lib/core/maps`, `lib/core/models`, `lib/core/services/navigation`, `lib/core/services/driver/*`),
  new tests (`test/core`, `test/user`, `test/web`), and new migration files. Nothing committed.
- App version: `1.0.0+1` (pubspec.yaml:19)
- Key deps: `flutter_map ^7.0.2`, `google_maps_flutter ^2.12.0` (present, not used for in-app map),
  `supabase_flutter ^2.8.0`, `geolocator ^14.0.3`, `url_launcher ^6.3.1`, `workmanager ^0.9.0`,
  `flutter_local_notifications ^18.0.1`, `firebase_core`/`firebase_messaging`.

Confirmed final architecture (via code inspection):
- Maps = `flutter_map` (FlutterMap) + MapTiler (`lib/core/maps/renderer/maptiler_config.dart`)
- Routing = GraphHopper (`lib/core/maps/providers/graphhopper_route_provider.dart`) + configured fallback
- Geocoding = MapTiler (`maptiler_geocoding_provider.dart`) + Nominatim fallback
  (`nominatim_geocoding_provider.dart`, `fallback_geocoding_provider.dart`)
- Tracking = Geolocator (`geolocator ^14.0.3`) + Supabase Realtime (`driver_tracking_session.dart`,
  `driver_locations` stream in `supabase_service.dart`)
- Navigation = `ExternalNavigationService` (`lib/core/services/navigation/`)

## 3. Device Inventory

| Device | Present? | Used? |
| ------ | -------- | ----- |
| Android + GMS | No | NOT TESTED |
| Huawei/Honor No-GMS | No | NOT TESTED |
| iPhone/iOS | No (no macOS) | NOT TESTED (build also N/A) |
| Web browser | Build only | NOT TESTED (no live GPS) |

## 4. MapTiler Live Validation
`NOT TESTED — NO PHYSICAL DEVICE AVAILABLE`. Code path compiled & web build succeeded; live tile
loading, light/dark mode, attribution not observed on a device.

## 5. Pick Location Validation
`NOT TESTED — NO PHYSICAL DEVICE AVAILABLE`.

## 6. Geocoding Validation
`NOT TESTED — NO PHYSICAL DEVICE AVAILABLE`. Forward/reverse logic exists
(`geocoding_service.dart`, providers). Live API quality/latency not measured.

## 7. User Order Journey
`NOT TESTED — NO PHYSICAL DEVICE AVAILABLE`. Code paths present; not exercised end-to-end.

## 8. Driver Order Journey
`NOT TESTED — NO PHYSICAL DEVICE AVAILABLE`.

## 9. Driver GPS Validation
`NOT TESTED`. Logic reviewed: `driver_tracking_session.dart` requests permission, starts Geolocator
position stream, applies `location_quality_filter`, publishes via `_defaultWriter`. Real GPS fix /
Supabase publish not observed.

## 10. User Live Tracking
`NOT TESTED`. `driver_tracking_screen.dart` + `live_tracking_screen.dart` render Realtime stream;
marker movement/ETA not observed on device.

## 11. Road Route Validation
`NOT TESTED`. Route polyline built from GraphHopper decoder (`polyline_decoder.dart`); real road
geometry not visually verified.

## 12. Marker Smoothness
`NOT TESTED`. `marker_interpolation.dart` present for smoothing; not observed on device.

## 13. Camera / Recenter
`NOT TESTED`.

## 14. Route Refresh / Rerouting
`NOT TESTED`. Reroute logic not device-verified.

## 15. Stale Location
`NOT TESTED`. `DriverLocation.isStale` (60s threshold) implemented and unit-testable; not observed live.

## 16. Network Loss / Recovery
`NOT TESTED`. `driver_tracking_session` implements bounded retry / reconnecting state
(`phase5_session_test.dart` covers transient failures in unit tests → **code validated**).

## 17. Background Tracking
`NOT TESTED`. `workmanager` + foreground-notification path present; real background continuation not observed.

## 18. Permission Handling
`NOT TESTED`. `permission_handler` + graceful checks present; not exercised on device.

## 19. Huawei/Honor/No-GMS
`NOT TESTED`. Internal map (FlutterMap+MapTiler) and tracking (Geolocator+Supabase) are GMS-independent
by design. External Navigation web fallback ensures no crash if Google Maps absent
(`external_navigation_service_test.dart` covers "all providers fail → noProvider").

## 20. External Navigation
**Code validated (YELLOW).** Unit tests (18) cover provider selection, fallback, and failure.
Real-device launch of Google/Waze/Apple not performed. Leakage audit: `lib/driver` contains **0**
references to `google.com/maps` / `_openGoogleMaps` / `LaunchMode.externalApplication`.

## 21. Notifications / FCM
`NOT TESTED` (push). Local/in-app path present. `FIS_AUTH_ERROR` (Phase 8) is external (Firebase
project / SHA-1 / Play Services on emulator) and not a code defect; not reproduced here.

## 22. Product Runtime Error Validation
**Code/test validated (GREEN-ish / YELLOW).** The prior `bool → int?` crash (`Product.fromJson`) is
fixed in `user`+`web` `all_products`/`getTopSeller` models via `_toInt`/`_toDouble` coercers; covered by
`test/user/product_model_test.dart` (4 tests pass). No type exception in tests.

## 23. UI Overflow Validation
**Code/test validated (YELLOW).** Prior `RenderFlex overflowed by 14px` in `build_side_bar.dart`
fixed (Text wrapped in `Expanded`); regression test present. Not device-rendered.

## 24. Auth
`NOT TESTED` live. `auth_cubit.completeRegistration` / `signUpDriver` are best-effort (Phase 6/7 fixes);
`flutter analyze` clean for auth. Not exercised on device.

## 25. Checkout / Payment
`NOT TESTED`. Checkout writes `delivery_lat`/`delivery_lng`/`delivery_address` (migration
`20260825000000` in `supabase/migrations/`). Paymob edge functions unchanged.

## 26. Chat
`NOT TESTED`. `OrderChatScreen` wiring present.

## 27. Security / RLS
Reviewed SQL (see §28). Findings:
- `driver_locations` write policy: `FOR ALL USING (auth.uid()=driver_id) WITH CHECK (auth.uid()=driver_id)`
  → driver can only write own location. **OK.**
- `notifications` INSERT policy: `FOR INSERT WITH CHECK (true)` → **any authenticated user may insert
  notifications for any `user_id`** (see BUG-002). Low impact but should be tightened (server-only insert).
- `orders` RLS hardened in Phase 7 (removed `allow_all_authenticated`). **OK** (script-level; live DB not queried).
- No service_role / private keys present in client code (Phase 8 audit). **OK.**

## 28. Production Database Verification
**NOT VERIFIED against a live database (no DB access).** Verified from SQL files only:

| Object | Expected columns | Source file | In auto-applied `supabase/migrations/`? |
| ------ | --------------- | ----------- | ---------------------------------------- |
| `orders` | `delivery_address`, `delivery_lat`, `delivery_lng` | `complete_supabase_schema.sql:157-159` + migration `20260825000000` | ✅ yes |
| `driver_locations` | `heading`, `speed`, `accuracy`, `last_seen`, `is_online` | `phase5_driver_locations.sql:7-11` | ❌ **NO — lives in `supabase/sql/` (ad-hoc)** |
| `notifications` | `push_sent` | migration `20260829000001` (in `migrations/`) | ✅ yes |

**CRITICAL GAP (BUG-001):** the `driver_locations` telemetry columns migration is an ad-hoc script
(`supabase/sql/phase5_driver_locations.sql`), NOT a numbered file under `supabase/migrations/`. Supabase
only auto-applies `supabase/migrations/`. `driver_tracking_session.dart:178-186` upserts
`heading/speed/accuracy/last_seen/is_online`. If this script was not manually run on the target DB,
those upserts fail (PostgREST 400 "column does not exist") → **live tracking writes break**. The all-in-one
`complete_supabase_schema.sql` also lacks these columns, so a fresh DB built from it has the same gap.

## 29. API Validation
`NOT TESTED` (no live keys/backend exercised). MapTiler/GraphHopper/Supabase/Firebase clients compile
and build; live calls not issued in this environment.

## 30. Performance
`NOT TESTED` (no measurements). `location_quality_filter` + `marker_interpolation` bound update rate /
smooth rendering; empirical latency/frequency not measured.

## 31. Cost Safety
**Code reviewed (YELLOW).** Routing fallback (GraphHopper → fallback) and geocoding fallback
(MapTiler → Nominatim) are bounded composites; no unbounded retry loop observed in code. `driver_tracking_session`
has bounded retry/reconnect. Not exercised under failure load.

## 32. Build Validation

| Artifact | Result | Note |
| -------- | ------ | ---- |
| User APK (debug) | ✅ Built | `app-user-debug.apk` |
| Driver APK (debug) | ✅ Built | `app-driver-debug.apk` (prior task) |
| Web | ✅ Built | `build/web` |
| iOS | ❌ Skipped | No macOS host |

## 33. Full Test Suite
`flutter test` → **111 passed** (93 pre-existing + 18 new navigation tests + prior phase tests). 0 failures.

## 34. Static Analysis
`flutter analyze` → **0 errors**, 1205 total issues (warnings + info lint hints, none new from this task).
Driver navigation leakage: 0 provider-specific URL references.

## 35. Bug List

### BUG-001
- ID: BUG-001
- Severity: **P1 (High)** — conditional on live DB state
- Platform: Backend / Supabase
- Device: N/A
- App: Driver (tracking write path)
- Screen: Driver online / tracking
- Steps: Driver goes online → `driver_tracking_session` upserts telemetry row
- Expected: row written to `driver_locations`
- Actual: if `phase5_driver_locations.sql` not applied, upsert fails (columns `heading/speed/accuracy/last_seen/is_online` missing)
- Reproducibility: certain on a DB built only from `supabase/migrations/` / `complete_supabase_schema.sql`
- Evidence: `driver_tracking_session.dart:178-186`; `supabase/sql/phase5_driver_locations.sql` (not in `migrations/`)
- Possible Area: DB migration deployment

### BUG-002
- ID: BUG-002
- Severity: **P3 (Low)** — security hardening
- Platform: Backend / Supabase
- App: All
- Screen: notifications
- Steps: authed user inserts notification
- Expected: only server/edge function inserts
- Actual: `notifications` INSERT policy `WITH CHECK (true)` allows any authed user to insert for any `user_id`
- Reproducibility: always (by policy)
- Evidence: `complete_supabase_schema.sql:257-258`
- Possible Area: RLS policy

### BUG-003
- ID: BUG-003
- Severity: **P3 (Low)** — external
- Platform: Firebase / FCM
- App: Driver/User
- Screen: notifications setup
- Steps: FCM token fetch on emulator
- Expected: token obtained
- Actual: `FIS_AUTH_ERROR` possible on emulator without SHA-1 / Play Services
- Reproducibility: emulator-specific
- Evidence: Phase 8 report; `notification_service_native.dart`
- Possible Area: Firebase project config (not code)

### BUG-004
- ID: BUG-004
- Severity: **P3 (Low)** — known design
- Platform: Driver
- App: Driver
- Screen: Navigate
- Steps: press Navigate
- Expected: opens external nav app
- Actual: provider availability resolved by OS routing https URL, not pre-probed; Waze ignores origin
- Reproducibility: by design
- Evidence: `external_navigation_service.dart`
- Possible Area: navigation (documented; acceptable)

## 36. Device Matrix

| Area                | Android GMS | Huawei/Honor | iOS | Web |
| ------------------- | ----------- | ------------ | --- | --- |
| Map                 | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Pick Location       | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Geocoding           | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Order Creation       | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Driver GPS          | NOT TESTED  | NOT TESTED   | N/A | N/A |
| Live Tracking       | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Route               | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| ETA                 | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Background          | NOT TESTED  | NOT TESTED   | N/A | N/A |
| Notifications       | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| External Navigation | CODE VALID  | CODE VALID   | N/A | CODE VALID |
| Orders              | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Auth                | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Chat                | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |
| Payment             | NOT TESTED  | NOT TESTED   | N/A | NOT TESTED |

## 37. Production Readiness Matrix

| Category            | Status | Evidence |
| ------------------- | ------ | -------- |
| Maps                | YELLOW | Build + code; no live device |
| Routing             | YELLOW | Build + code; no live API |
| Geocoding           | YELLOW | Build + code; no live API |
| GPS                 | YELLOW | Code reviewed; no device |
| Live Tracking       | YELLOW | Code + unit tests; no device/live DB |
| Background Tracking | YELLOW | Code present; no device |
| External Navigation | YELLOW | 18 unit tests + build; no device |
| Realtime            | YELLOW | Code + unit tests; no live DB |
| Notifications       | YELLOW | Code; FCM external caveat |
| Orders              | YELLOW | Code + migration; no device |
| Security            | YELLOW | RLS reviewed; BUG-002 open |
| Database            | YELLOW | BUG-001 migration gap (apply before release) |
| Android             | YELLOW | APK builds; no device |
| Huawei/Honor        | YELLOW | GMS-independent by design; no device |
| iOS                 | RED*   | Not built (no macOS) — *red only for iOS artifact, not code |
| Web                 | YELLOW | Web build OK; no live GPS |

## 38. RED / YELLOW / GREEN

- GREEN: Static analysis (0 errors), full test suite (111 passed), External Navigation abstraction
  (unit-tested + leakage-clean), Product bool→int fix (tested), UI overflow fix (tested),
  User/Driver/Web builds succeed.
- YELLOW: All real-device / live-API / live-DB behaviors (no physical device, no live backend in env).
- RED: None in code. iOS artifact not built (environment limitation, not a defect).
- **P1 prerequisite:** BUG-001 — `driver_locations` telemetry migration must be applied to the live DB
  or live tracking writes will fail.

## 39. Production Blockers

### RED BLOCKERS
- None confirmed in code.

### YELLOW PREREQUISITES
1. **BUG-001** — Apply `supabase/sql/phase5_driver_locations.sql` (or promote it to
   `supabase/migrations/<timestamp>_add_driver_location_telemetry.sql`) to the target database before
   release, so `heading/speed/accuracy/last_seen/is_online` exist. Verify with
   `SELECT column_name FROM information_schema.columns WHERE table_name='driver_locations'`.
2. Real-device QA (Android GMS + Huawei/No-GMS + iOS + Web) not performed in this environment — schedule
   on physical devices with live credentials.
3. **BUG-002** — Tighten `notifications` INSERT RLS (server-only) before public launch.
4. **BUG-003** — Resolve FCM `FIS_AUTH_ERROR` on real devices (SHA-1 / Play Services / Firebase project).

### GREEN VERIFIED
- `flutter analyze`: 0 errors
- `flutter test`: 111 passed
- User / Driver APK + Web builds succeed
- External Navigation: no driver-UI provider leakage; fallback + failure handling unit-tested
- Prior runtime crashes (bool→int, sidebar overflow) fixed and tested

## 40. Recommended Fixes (NOT applied — awaiting your approval)

1. **BUG-001 (P1):** Promote `phase5_driver_locations.sql` into `supabase/migrations/` as a numbered
   migration (e.g. `20260829000002_add_driver_location_telemetry.sql`) so it auto-applies; OR document
   that it must be run manually on every target DB. (Deployment step, not a Dart change.)
2. **BUG-002 (P3):** Change `notifications` INSERT policy to `WITH CHECK (auth.uid() = user_id)` (or
   server-only) to prevent cross-user notification insertion.
3. **BUG-003 (P3):** Add SHA-1 debug fingerprint in Firebase Console / test on real device.
4. (Optional) BUG-004: add explicit provider pre-detection if OS-routing behavior is insufficient.

## 41. FINAL QA STATUS

## CONDITIONAL RELEASE

Rationale: The codebase, builds, static analysis, and automated tests are release-ready (GREEN on all
build/analyze/test axes). Two classes of conditions remain, neither a confirmed code defect:
(a) **real-device and live-backend validation could not be performed in this environment**
(NO PHYSICAL DEVICE AVAILABLE) — must be completed on physical devices with live credentials; and
(b) **one P1 deployment prerequisite (BUG-001)** — the `driver_locations` telemetry-column migration is
not in the auto-applied `supabase/migrations/` folder and must be applied to the live DB, otherwise live
tracking writes fail. Resolve BUG-001 and perform device QA before production ship.

---

*No code was modified during this QA task. Awaiting explicit instructions before any fix.*
