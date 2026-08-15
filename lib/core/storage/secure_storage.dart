import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage for sensitive values (auth tokens, credentials, ...), backed by
/// the platform keystore/keychain instead of plain preferences.
///
/// Nothing currently writes to this — it exists as the designated home for
/// secrets introduced by future features (e.g. submissions auth).
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
