import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save login credentials for "Remember Me" functionality
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: 'remembered_email', value: email);
    await _storage.write(key: 'remembered_password', value: password);
  }

  /// Get saved credentials
  Future<Map<String, String?>> getCredentials() async {
    return {
      'email': await _storage.read(key: 'remembered_email'),
      'password': await _storage.read(key: 'remembered_password'),
    };
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    await _storage.delete(key: 'remembered_email');
    await _storage.delete(key: 'remembered_password');
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    final email = await _storage.read(key: 'remembered_email');
    return email != null && email.isNotEmpty;
  }
}
