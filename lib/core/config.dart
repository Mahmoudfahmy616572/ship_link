class AppConfig {
  // Values are injected at build time via `--dart-define-from-file=.env`.
  // The real values live in `.env` (gitignored) and are NEVER committed.
  // `.env.example` documents the required keys.
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
}
