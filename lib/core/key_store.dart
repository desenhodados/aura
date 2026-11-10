import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gera e guarda (Keychain/Keystore) a chave AES de 32 bytes que encripta os dados.
class KeyStore {
  static const _storage = FlutterSecureStorage();
  static const _k = 'db_key_v2';

  static Future<List<int>> obterChave() async {
    final guardada = await _storage.read(key: _k);
    if (guardada != null) return base64Url.decode(guardada);
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    await _storage.write(key: _k, value: base64UrlEncode(bytes));
    return bytes;
  }
}
