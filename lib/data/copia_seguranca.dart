import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Ficheiro .aura = "AURA1" + iterações(4) + sal(16) + nonce(12) + mac(16) + dados.
/// Dados cifrados com AES-256-GCM; a chave vem da palavra-passe (PBKDF2-SHA256).
class CopiaSeguranca {
  static final List<int> _magic = utf8.encode('AURA1');
  static const _iteracoes = 120000;

  static Future<SecretKey> _chave(String palavraPasse, List<int> sal, int iter) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iter, bits: 256)
          .deriveKeyFromPassword(password: palavraPasse, nonce: sal);

  static Future<Uint8List> cifrar(
      Map<String, dynamic> dados, String palavraPasse) async {
    final rnd = Random.secure();
    final sal = List<int>.generate(16, (_) => rnd.nextInt(256));
    final chave = await _chave(palavraPasse, sal, _iteracoes);
    final caixa = await AesGcm.with256bits()
        .encrypt(utf8.encode(jsonEncode(dados)), secretKey: chave);

    final iter = ByteData(4)..setUint32(0, _iteracoes);
    final out = BytesBuilder()
      ..add(_magic)
      ..add(iter.buffer.asUint8List())
      ..add(sal)
      ..add(caixa.nonce)
      ..add(caixa.mac.bytes)
      ..add(caixa.cipherText);
    return out.toBytes();
  }

  /// Lança [FormatException] com uma mensagem para mostrar ao utilizador.
  static Future<Map<String, dynamic>> decifrar(
      Uint8List b, String palavraPasse) async {
    const cabecalho = 5 + 4 + 16 + 12 + 16;
    if (b.length <= cabecalho) {
      throw const FormatException('Este ficheiro não é uma cópia da Aura.');
    }
    for (var i = 0; i < _magic.length; i++) {
      if (b[i] != _magic[i]) {
        throw const FormatException('Este ficheiro não é uma cópia da Aura.');
      }
    }
    final iter = ByteData.sublistView(b, 5, 9).getUint32(0);
    if (iter < 1000 || iter > 2000000) {
      throw const FormatException('Ficheiro danificado.');
    }
    final sal = b.sublist(9, 25);
    final nonce = b.sublist(25, 37);
    final mac = b.sublist(37, 53);
    final cifra = b.sublist(53);

    final chave = await _chave(palavraPasse, sal, iter);
    try {
      final claro = await AesGcm.with256bits().decrypt(
        SecretBox(cifra, nonce: nonce, mac: Mac(mac)),
        secretKey: chave,
      );
      return Map<String, dynamic>.from(jsonDecode(utf8.decode(claro)) as Map);
    } catch (_) {
      throw const FormatException(
          'Palavra-passe errada ou ficheiro danificado.');
    }
  }
}
