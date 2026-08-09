/// Compile-time application configuration.
///
/// Values are supplied with Flutter's `--dart-define` or
/// `--dart-define-from-file` flags. The production API remains the safe
/// default for builds that do not provide an override.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kompak-api.muriz.workers.dev',
  );
}
