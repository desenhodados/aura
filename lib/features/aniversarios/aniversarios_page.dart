import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/aniversarios.dart';
import '../../core/avatar_paciente.dart';
import '../../core/contactos.dart';
import '../../core/providers.dart';
import '../../core/texto_doc.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

const mensagemParabensPadrao =
    'Olá {primeiro_nome}! 🎂 Parabéns pelo seu aniversário! '
    'Desejo-lhe um dia muito feliz, com muita saúde e alegria. Um abraço.';

/// Abre a mensagem de parabéns (editável) com os botões de WhatsApp e e-mail.
Future<void> abrirParabens(BuildContext context, Paciente p) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _ParabensSheet(paciente: p),
    );

class _ParabensSheet extends ConsumerStatefulWidget {
  const _ParabensSheet({required this.paciente});
  final Paciente paciente;
  @override
  ConsumerState<_ParabensSheet> createState() => _ParabensSheetState();
}

class _ParabensSheetState extends ConsumerState<_ParabensSheet> {
  late final TextEditingController _texto = TextEditingController(
      text: ref.read(repoProvider).mensagemAniversario ?? mensagemParabensPadrao);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  String get _final =>
      substituirMarcadores(_texto.text, widget.paciente, DateTime.now());

  void _aviso(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.paciente;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Parabéns, ${primeiroNomeSimples(p.nome)}!',
                style: fonteTitulo.copyWith(fontSize: 22),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextField(
              controller: _texto,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Mensagem (podes alterar)',
                helperText: '{primeiro_nome} é trocado pelo nome da paciente',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E9E5B),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                try {
                  final ok = await abrirWhatsApp(p.telemovel, _final);
                  if (!ok) _aviso('Não foi possível abrir o WhatsApp.');
                } catch (_) {
                  _aviso('Não foi possível abrir o WhatsApp.');
                }
              },
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Enviar por WhatsApp'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                try {
                  final ok = await abrirEmail(p.email, 'Parabéns!', _final);
                  if (!ok) _aviso('Não foi possível abrir o e-mail.');
                } catch (_) {
                  _aviso('Não foi possível abrir o e-mail.');
                }
              },
              icon: const Icon(Icons.email_outlined),
              label: const Text('Enviar por e-mail'),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(repoProvider)
                    .guardarMensagemAniversario(_texto.text.trim());
                _aviso('Guardada como mensagem padrão.');
              },
              child: const Text('Guardar como mensagem padrão'),
            ),
          ],
        ),
      ),
    );
  }
}

String primeiroNomeSimples(String nome) {
  final t = nome.trim();
  return t.isEmpty ? '' : t.split(RegExp(r'\s+')).first;
}

/// Aniversários de hoje e dos próximos 30 dias.
class AniversariosPage extends ConsumerWidget {
  const AniversariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosPacientesProvider).valueOrNull ?? [];
    final lista = proximosAniversarios(todos, DateTime.now(), dias: 30);
    final hoje = lista.where((a) => a.dias == 0).toList();
    final seguintes = lista.where((a) => a.dias > 0).toList();

    Widget linha(Aniversario a) => AuraCard(
          child: ListTile(
            leading: AvatarPaciente(a.paciente, raio: 22),
            title: Text(a.paciente.nome,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${DateFormat('dd/MM').format(a.data)} · faz ${a.idade} anos · ${textoQuando(a.dias)}'),
            trailing: FilledButton.tonalIcon(
              onPressed: () => abrirParabens(context, a.paciente),
              icon: const Icon(Icons.cake_outlined, size: 18),
              label: const Text('Parabéns'),
            ),
          ),
        );

    Widget titulo(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(t, style: fonteTitulo.copyWith(fontSize: 18)),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Aniversários', style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: lista.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Sem aniversários nos próximos 30 dias.\nPara aparecerem aqui, regista a data de nascimento na identificação de cada paciente.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                if (hoje.isNotEmpty) ...[
                  titulo('Hoje 🎂'),
                  for (final a in hoje)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8), child: linha(a)),
                ],
                if (seguintes.isNotEmpty) ...[
                  titulo('Próximos 30 dias'),
                  for (final a in seguintes)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8), child: linha(a)),
                ],
                const SizedBox(height: 8),
                const Text(
                  'A Aura avisa-te quando a abres. A mensagem abre no WhatsApp ou no e-mail, e tens de carregar em enviar.',
                  style: TextStyle(color: AuraCores.textoSuave, fontSize: 13),
                ),
              ],
            ),
    );
  }
}
