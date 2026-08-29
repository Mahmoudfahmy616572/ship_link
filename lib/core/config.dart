class AppConfig {
  // Values are injected at build time via `--dart-define-from-file=.env`
  // (or `--dart-define=SUPABASE_URL=...`). The `.env` file is gitignored.
  // Sensible defaults are provided so the app works out-of-the-box when the
  // dart-define is omitted (e.g. `flutter run` from an IDE). The publishable
  // anon key is public by design and safe to embed in a client build.
  // `--dart-define` still overrides these for other environments.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aqxiziqybgtvrdfhmmoc.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MjI5MDUsImV4cCI6MjA5NzI5ODkwNX0.vohe0h4gzDZSRttscc6c2RXREIv6Nt7WawxSoavFG6w',
  );
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyDi2u6Qio7v1VaQxwgZDmxAdAsmINY51cs',
  );
}
