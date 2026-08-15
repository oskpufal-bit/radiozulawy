import 'app_environment.dart';

/// Central runtime configuration for the app.
///
/// All values are resolved at compile time via `--dart-define`/
/// `--dart-define-from-file`, never hardcoded in feature code. When a value
/// is not supplied at build time we fall back to a development placeholder
/// pointing at the `.invalid` TLD (reserved by RFC 2606), so an unconfigured
/// build can never reach a real network host by accident.
///
/// See docs/DEV_PLACEHOLDERS.md for the full registry of placeholders and
/// what must replace them before a production release.
class AppConfig {
  const AppConfig._();

  static final AppEnvironment environment = AppEnvironment.fromName(
    String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
  );

  static const String radioStreamUrl = String.fromEnvironment(
    'RADIO_STREAM_URL',
    defaultValue: 'https://stream.dev-placeholder.invalid/radiozulawy.mp3',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev-placeholder.invalid',
  );

  static const String wordpressApiUrl = String.fromEnvironment(
    'WORDPRESS_API_URL',
    defaultValue: 'https://cms.dev-placeholder.invalid/wp-json/wp/v2',
  );

  static const String submissionsApiUrl = String.fromEnvironment(
    'SUBMISSIONS_API_URL',
    defaultValue: 'https://api.dev-placeholder.invalid/submissions',
  );

  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://dev-placeholder.invalid/polityka-prywatnosci',
  );

  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://dev-placeholder.invalid/regulamin',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Whether any placeholder value is still active. Useful for a future
  /// startup diagnostic/banner; intentionally unused for now.
  static bool get isUsingPlaceholderConfig =>
      apiBaseUrl.contains('.invalid') ||
      wordpressApiUrl.contains('.invalid') ||
      submissionsApiUrl.contains('.invalid') ||
      radioStreamUrl.contains('.invalid');
}
