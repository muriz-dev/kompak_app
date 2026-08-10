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

  static const mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const mapAttribution = String.fromEnvironment(
    'MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  static const mapUserAgentPackageName = String.fromEnvironment(
    'MAP_USER_AGENT_PACKAGE_NAME',
    defaultValue: 'com.example.kompak_app',
  );
}
