import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/config/app_config.dart';

void main() {
  test('exposes a compile-time API base URL', () {
    expect(AppConfig.apiBaseUrl, isNotEmpty);
    expect(AppConfig.apiBaseUrl, startsWith('http'));
  });

  test('exposes compile-time map configuration', () {
    expect(AppConfig.mapTileUrl, contains('{z}'));
    expect(AppConfig.mapTileUrl, contains('{x}'));
    expect(AppConfig.mapTileUrl, contains('{y}'));
    expect(AppConfig.mapAttribution, isNotEmpty);
    expect(AppConfig.mapUserAgentPackageName, isNotEmpty);
  });
}
