import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Número para o WhatsApp: só dígitos, com indicativo (assume Portugal se tiver 9 dígitos).
String? normalizarTelemovel(String? t) {
  if (t == null) return null;
  var n = t.replaceAll(RegExp(r'[^0-9]'), '');
  if (n.isEmpty) return null;
  if (n.startsWith('00')) n = n.substring(2);
  if (n.length == 9 && RegExp(r'^[239]').hasMatch(n)) n = '351$n';
  return n;
}

/// Web app num telemóvel ou tablet (iPhone, iPad, Android no navegador).
bool get _webMovel =>
    kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Abre o WhatsApp com a mensagem pronta (para o número do paciente, se existir).
///
/// Na web app instalada no iPhone/iPad, um link https abria uma janela do
/// Safari que ficava em branco depois de voltar. Por isso, nesse caso abre-se
/// diretamente a app do WhatsApp (whatsapp://) na própria janela.
Future<bool> abrirWhatsApp(String? telemovel, String texto) async {
  final n = normalizarTelemovel(telemovel);
  final msg = Uri.encodeComponent(texto);

  if (_webMovel) {
    final app = Uri.parse(n == null
        ? 'whatsapp://send?text=$msg'
        : 'whatsapp://send?phone=$n&text=$msg');
    return launchUrl(app, webOnlyWindowName: '_self');
  }

  final uri = Uri.parse(n == null
      ? 'https://wa.me/?text=$msg'
      : 'https://wa.me/$n?text=$msg');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Abre a aplicação de e-mail com assunto e texto prontos.
Future<bool> abrirEmail(String? email, String assunto, String corpo) {
  final para = (email ?? '').trim();
  final uri = Uri.parse(
      'mailto:$para?subject=${Uri.encodeComponent(assunto)}&body=${Uri.encodeComponent(corpo)}');
  // '_self': na web não abre um separador em branco.
  return launchUrl(uri, webOnlyWindowName: '_self');
}

/// Abre o marcador do telemóvel com o número da paciente.
Future<bool> abrirChamada(String? telemovel) {
  final n = normalizarTelemovel(telemovel);
  if (n == null) return Future.value(false);
  return launchUrl(Uri(scheme: 'tel', path: '+$n'), webOnlyWindowName: '_self');
}
