import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  // Claves
  static const String _keyWalletAddress = 'wallet_address';
  static const String _keySessionToken = 'session_token';
  static const String _keyUserAlias = 'user_alias';

  // --- Guardar ---
  Future<void> saveWalletAddress(String address) async {
    await _storage.write(key: _keyWalletAddress, value: address);
  }

  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _keySessionToken, value: token);
  }

  Future<void> saveUserAlias(String alias) async {
    await _storage.write(key: _keyUserAlias, value: alias);
  }

  // --- Leer ---
  Future<String?> getWalletAddress() async {
    return await _storage.read(key: _keyWalletAddress);
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: _keySessionToken);
  }
  
  Future<String?> getUserAlias() async {
    return await _storage.read(key: _keyUserAlias);
  }

  // --- Borrar (Logout) ---
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
