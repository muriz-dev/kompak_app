import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

@LazySingleton(as: SessionTokenStore)
class SecureSessionTokenStore implements SessionTokenStore {
  SecureSessionTokenStore(this._secureStorage, this._preferences);

  static const _tokenKey = 'jwt_token';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  @override
  Future<String?> read() async {
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;

    final legacyToken = _preferences.getString(_tokenKey);
    if (legacyToken == null || legacyToken.isEmpty) return null;

    await _secureStorage.write(key: _tokenKey, value: legacyToken);
    await _preferences.remove(_tokenKey);
    return legacyToken;
  }

  @override
  Future<void> write(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() async {
    await _secureStorage.delete(key: _tokenKey);
    await _preferences.remove(_tokenKey);
  }
}
