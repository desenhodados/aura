import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/contactos.dart';
import '../../core/tema.dart';
import '../../core/versao.dart';

/// Envia críticas e sugestões por e-mail.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const _tipos = ['Crítica', 'Sugestão', 'Erro', 'Elogio'];
  String _tipo = _tipos.first;
  final _texto = TextEditingController();

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  String get _corpo =>
      '${_texto.text.trim()}\n\n---\nAplicação: Aura $versaoApp\nTipo: $_tipo';

  Future<void> _enviar() async {
    var ok = false;
    try {
      ok = await abrirEmail(
          emailFeedback, 'Feedback Aura $versaoApp - $_tipo', _corpo);
    } catch (_) {}
    if (!ok && mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Não foi possível abrir o e-mail'),
          content: const Text(
              'Envia a tua mensagem para desenhodados@gmail.com. '
              'Podes copiar o endereço e a mensagem.'),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: emailFeedback));
                Navigator.pop(ctx);
              },
              child: const Text('Copiar endereço'),
            ),
            FilledButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _corpo));
                Navigator.pop(ctx);
              },
              child: const Text('Copiar mensagem'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Feedback', style: fonteTitulo.copyWith(fontSize: 20)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'As tuas críticas e sugestões ajudam a melhorar a Aura. '
              'A mensagem é enviada por e-mail para $emailFeedback.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _tipos)
                  ChoiceChip(
                    label: Text(t),
                    selected: _tipo == t,
                    onSelected: (_) => setState(() => _tipo = t),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _texto,
              minLines: 8,
              maxLines: 16,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'A tua mensagem',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Não incluas dados de pacientes na mensagem.',
              style: TextStyle(color: AuraCores.textoSuave, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AuraCores.rosa,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _texto.text.trim().isEmpty ? null : _enviar,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Enviar por e-mail'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: emailFeedback));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Endereço copiado')));
              },
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copiar o endereço de e-mail'),
            ),
          ],
        ),
      );
}
