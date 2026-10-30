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

/// Abre o WhatsApp com a mensagem pronta (para o número do paciente, se existir).
Future<bool> abrirWhatsApp(String? telemovel, String texto) {
  final n = normalizarTelemovel(telemovel);
  final msg = Uri.encodeComponent(texto);
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
  return launchUrl(uri);
}
