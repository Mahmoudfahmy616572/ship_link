## Objective
- Rebuild web app (`lib/web/`) with full user app features matching architecture (models, repos, data sources, DI, Cubits).
- Replace existing Provider/ChangeNotifier pattern with Bloc/Cubits.
- Build missing web screens: Auth, Product, Search, Chat, Tracking, Orders, etc.

## Important Details
- Release APK crash fixed by disabling R8 (`minifyEnabled false, shrinkResources false`).
- `compileSdk 36` forced via `afterEvaluate` hook in `android/build.gradle` (required by `device_info_plus 13.2.0` / `package_info_plus 10.2.0`).
- Web data layer uses Supabase directly; no `CacheService` (sqflite/secure_storage not web-compatible).
- AuthCubit conflict with `gotrue.AuthState` resolved via `hide AuthState` on Supabase imports.
- `flutter build web --release` succeeds (only pre-existing `dart:html` + wasm warnings in `checkout_web.dart`, `payment_methods_web.dart`, `web_invoice_download.dart`).

## Work State
### Completed
- **Release APK**: disabled R8 minification; `compileSdk 36`; APK size reduction (asset deletion, PNG→WebP, `--split-debug-info`)
- **Web data layer**: 7 models, 5 domain repos, 5 data sources, 5 repo impls, `getIt` DI
- **Web Cubits**: 18 cubit sets created (Auth, AddToCart, ChatList, OrderChat, SupportChat, ConfirmCart, Favourite, GetAllProducts, GetFromCart, GetTopSeller, HomeFilter, Notification, OrderHistory, Payment, Search, Address, ProfileEdit, Checkout, OrderDetail)
- **All existing screens refactored to Cubits**: WebScaffold, LoginWeb, RegisterWeb, SettingsWeb, SecurityWeb, ProfileWeb, HomeWeb, CartWeb, FavouriteWeb, OrdersWeb, NotificationsWeb, AddressesWeb, EditProfileWeb, OrderDetailWeb, CheckoutWeb
- **Phase 1 – Auth screens** (5 new screens): Splash, Welcome, OTP, CreateAccount, ResetPassword
- **Phase 1 – Product & Search screens** (2 new screens): ProductDetailsWeb (multi-image carousel, reviews, add to cart, favourite), SearchWeb (search bar, category chips, price filter, sort)
- **Routes**: all 7 new screens registered in `routs_web.dart`; `initialRoute` changed to `/splash`

### Active
- *(none)*

### Blocked
- *(none)*

## Next Move
1. Remove old unused `LoginWeb`/`RegisterWeb` screens (routes kept for backward compat, but no screen navigates to them anymore)
2. Remove old `auth_service_web.dart` file (unused now that AuthCubit handles auth)
3. Consider Phase 4 features (admin dashboard, analytics, etc.)

## Relevant Files
- `lib/web/presentation/screens/splash/splash_web.dart`: SplashWeb (route `/splash`)
- `lib/web/presentation/screens/welcome/welcome_web.dart`: WelcomeWeb (route `/welcome`)
- `lib/web/presentation/screens/otp/otp_web.dart`: OtpWeb (route `/otp`)
- `lib/web/presentation/screens/create_account/create_account_web.dart`: CreateAccountWeb (route `/create-account`)
- `lib/web/presentation/screens/reset_password/reset_password_web.dart`: ResetPasswordWeb (route `/reset-password`)
- `lib/web/presentation/screens/product_details/product_details_web.dart`: ProductDetailsWeb (route `/product-details`)
- `lib/web/presentation/screens/search/search_web.dart`: SearchWeb (route `/search`)
- `lib/web/presentation/cubits/address/`: AddressCubit
- `lib/web/presentation/cubits/profileEdit/`: ProfileEditCubit
- `lib/web/presentation/cubits/checkout/`: CheckoutCubit
- `lib/web/presentation/cubits/orderDetail/`: OrderDetailCubit
- `lib/web/data/services_locators.dart`: registers all repos + cubits
- `lib/web/main_web.dart`: MultiBlocProvider wrapping all cubits
- `lib/web/routs_web.dart`: all routes registered
