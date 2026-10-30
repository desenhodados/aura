import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'descarregar_stub.dart' if (dart.library.html) 'descarregar_web.dart';

/// Abre a folha de partilha (Ficheiros, iCloud, AirDrop, e-mail...).
/// Na web, se não for possível, descarrega o ficheiro.
Future<void> entregarFicheiro(Uint8List bytes, String nome, Rect? zona) async {
  try {
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: nome, mimeType: 'application/octet-stream')],
      fileNameOverrides: [nome],
      subject: nome,
      sharePositionOrigin: zona,
    );
  } catch (_) {
    if (kIsWeb) {
      descarregar(bytes, nome);
    } else {
      rethrow;
    }
  }
}
