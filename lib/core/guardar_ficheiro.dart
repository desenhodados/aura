import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
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

/// Abre o seletor do sistema ("Guardar em...") para o utilizador escolher a
/// pasta onde guardar o ficheiro. Devolve false se cancelou.
/// Na web, o navegador decide a pasta (transferências ou pergunta).
Future<bool> guardarNumaPasta(Uint8List bytes, String nome) async {
  if (kIsWeb) {
    await entregarFicheiro(bytes, nome, null);
    return true;
  }
  final caminho = await FilePicker.platform.saveFile(
    dialogTitle: 'Escolhe a pasta para guardar o backup',
    fileName: nome,
    bytes: bytes,
  );
  return caminho != null;
}
