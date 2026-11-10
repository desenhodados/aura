import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import 'ficha_campos.dart';
import 'ficha_modelo.dart';

/// Edita só uma secção da ficha (sem passar pelo formulário todo).
Future<void> abrirEditorSeccao(
        BuildContext context, String pacienteId, Secao seccao) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: _EditorSeccao(pacienteId: pacienteId, seccao: seccao),
      ),
    );

/// Lista todas as secções para escolher qual editar (mesmo as ainda vazias).
Future<void> abrirEscolherSeccao(
    BuildContext context, String pacienteId, Map<String, dynamic> dados) async {
  final escolhida = await showModalBottomSheet<Secao>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (ctx) => ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('Que secção queres editar?',
              style: fonteTitulo.copyWith(fontSize: 22)),
        ),
        for (final s in secoes)
          ListTile(
            title: Text(s.titulo),
            subtitle: Text(() {
              final n = linhasPreenchidas(s, dados).length;
              return n == 0 ? 'Por preencher' : '$n campo(s) preenchido(s)';
            }()),
            trailing: const Icon(Icons.edit_outlined, color: AuraCores.rosa),
            onTap: () => Navigator.pop(ctx, s),
          ),
      ],
    ),
  );
  if (escolhida != null && context.mounted) {
    await abrirEditorSeccao(context, pacienteId, escolhida);
  }
}

class _EditorSeccao extends ConsumerStatefulWidget {
  const _EditorSeccao({required this.pacienteId, required this.seccao});
  final String pacienteId;
  final Secao seccao;
  @override
  ConsumerState<_EditorSeccao> createState() => _EditorSeccaoState();
}

class _EditorSeccaoState extends ConsumerState<_EditorSeccao> {
  final Map<String, dynamic> _dados = {};
  bool _carregado = false;
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final f = await ref.read(repoProvider).lerFicha(widget.pacienteId);
    final todos = dadosDe(f);
    for (final c in widget.seccao.campos) {
      if (todos.containsKey(c.chave)) _dados[c.chave] = todos[c.chave];
    }
    if (mounted) setState(() => _carregado = true);
  }

  Future<void> _guardar() async {
    setState(() => _aGuardar = true);
    final repo = ref.read(repoProvider);
    // lê a ficha mais recente e só altera os campos desta secção
    final f = await repo.lerFicha(widget.pacienteId);
    final dados = dadosDe(f);
    for (final c in widget.seccao.campos) {
      final v = _dados[c.chave];
      final vazio = v == null ||
          (v is String && v.trim().isEmpty) ||
          (v is List && v.isEmpty);
      if (vazio) {
        dados.remove(c.chave);
      } else {
        dados[c.chave] = v;
      }
    }
    await repo.guardarFicha(Ficha(
      pacienteId: widget.pacienteId,
      dadosJson: jsonEncode(dados),
      tratamentosPropostosJson: f?.tratamentosPropostosJson ?? '[]',
      atualizadaEm: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.seccao.titulo,
                    style: fonteTitulo.copyWith(fontSize: 24)),
              ),
            ),
            Expanded(
              child: !_carregado
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      children: [
                        for (final c in widget.seccao.campos)
                          construirCampo(context, c, _dados, setState, () {}),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AuraCores.rosa),
                      onPressed: _carregado && !_aGuardar ? _guardar : null,
                      child: Text(_aGuardar ? 'A guardar...' : 'Guardar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
