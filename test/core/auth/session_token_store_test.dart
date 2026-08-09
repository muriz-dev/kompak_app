import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'migrates the legacy shared-preferences token to secure storage',
    () async {
      SharedPreferences.setMockInitialValues({'jwt_token': 'legacy-token'});
      final preferences = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      final store = SecureSessionTokenStore(secureStorage, preferences);

      expect(await store.read(), 'legacy-token');
      expect(preferences.getString('jwt_token'), isNull);
      expect(await secureStorage.read(key: 'jwt_token'), 'legacy-token');
    },
  );

  test('clears both secure and legacy token locations', () async {
    SharedPreferences.setMockInitialValues({'jwt_token': 'legacy-token'});
    FlutterSecureStorage.setMockInitialValues({'jwt_token': 'secure-token'});
    final preferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final store = SecureSessionTokenStore(secureStorage, preferences);

    await store.clear();

    expect(await secureStorage.read(key: 'jwt_token'), isNull);
    expect(preferences.getString('jwt_token'), isNull);
  });
}
