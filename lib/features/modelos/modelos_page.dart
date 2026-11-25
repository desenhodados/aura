import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../../core/interacao.dart';

/// Modelos de documentos: consentimentos informados e recomendações pós-tratamento.
/// Podes editar o texto, apagar e criar novos.
class ModelosPage extends ConsumerWidget {
  const ModelosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Modelos de documentos',
                style: fonteTitulo.copyWith(fontSize: 20)),
            bottom: const TabBar(
              labelColor: AuraCores.texto,
              indicatorColor: AuraCores.rosa,
              tabs: [Tab(text: 'Consentimentos'), Tab(text: 'Recomendações')],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'repor') {
                    await ref.read(repoProvider).reporModelosPadrao();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Modelos originais repostos')));
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'repor',
                    child: Text('Repor modelos originais apagados'),
                  ),
                ],
              ),
            ],
          ),
          body: const TabBarView(
            children: [_Lista('consentimento'), _Lista('recomendacao')],
          ),
        ),
      );
}

class _Lista extends ConsumerWidget {
  const _Lista(this.tipo);
  final String tipo;

  String _primeiraLinha(String t) {
    for (final l in t.split('\n')) {
      final s = l.trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelos = ref.watch(modelosProvider(tipo)).valueOrNull ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () => context.abrir('/modelos/novo/$tipo'),
          icon: const Icon(Icons.add),
          label: Text(tipo == 'consentimento'
              ? 'Novo modelo de consentimento'
              : 'Novo modelo de recomendações'),
        ),
        const SizedBox(height: 12),
        if (modelos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Sem modelos.', textAlign: TextAlign.center),
          ),
        for (final m in modelos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AuraCard(
              child: ListTile(
                leading: const Icon(Icons.description_outlined,
                    color: AuraCores.rosa),
                title: Text(m.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_primeiraLinha(m.texto),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => context.abrir('/modelos/editar/${m.id}'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Criar ou editar um modelo.
class EditarModeloPage extends ConsumerStatefulWidget {
  const EditarModeloPage({super.key, this.modeloId, this.tipo});
  final String? modeloId;
  final String? tipo; // 'consentimento' | 'recomendacao' (para novo)
  @override
  ConsumerState<EditarModeloPage> createState() => _EditarModeloPageState();
}

class _EditarModeloPageState extends ConsumerState<EditarModeloPage> {
  final _titulo = TextEditingController();
  final _tituloDoc = TextEditingController();
  final _texto = TextEditingController();
  Modelo? _existente;
  bool _carregado = false;
  bool _aGuardar = false;
  String _original = '';

  String _estado() => [
        _titulo.text.trim(),
        _tituloDoc.text.trim(),
        _texto.text.trim()
      ].join('|');

  bool get _alterado => _carregado && _estado() != _original;

  void _atualizar() {
    if (mounted) setState(() {});
  }

  String get _tipo => _existente?.tipo ?? widget.tipo ?? 'consentimento';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final id = widget.modeloId;
    if (id != null) {
      final m = await ref.read(repoProvider).lerModelo(id);
      if (m != null) {
        _existente = m;
        _titulo.text = m.titulo;
        _tituloDoc.text = m.tituloDoc;
        _texto.text = m.texto;
      }
    }
    _original = _estado();
    for (final c in [_titulo, _tituloDoc, _texto]) {
      c.addListener(_atualizar);
    }
    if (mounted) setState(() => _carregado = true);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _tituloDoc.dispose();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty || _texto.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indica o nome e o texto do modelo.')));
      return;
    }
    if (_aGuardar) return;
    final tituloDoc = _tituloDoc.text.trim().isEmpty
        ? titulo.toUpperCase()
        : _tituloDoc.text.trim();
    setState(() => _aGuardar = true);
    try {
      await ref.read(repoProvider).guardarModelo(Modelo(
            id: _existente?.id ?? 'm_${const Uuid().v4()}',
            tipo: _tipo,
            titulo: titulo,
            tituloDoc: tituloDoc,
            texto: _texto.text.trim(),
            atualizadoEm: DateTime.now(),
          ));
      if (mounted) context.pop();
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _aGuardar = false);
      await avisarErro(
          context, 'Não foi possível guardar o modelo. Tenta de novo.', e, st);
    }
  }

  Future<void> _apagar() => umaVez(this, () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Apagar "${_existente!.titulo}"?'),
            content: const Text(
                'Os consentimentos já assinados não são afetados (guardam a sua própria cópia).'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Apagar')),
            ],
          ),
        );
        if (ok != true) return;
        try {
          await ref.read(repoProvider).apagarModelo(_existente!.id);
          if (mounted) context.pop();
        } catch (e, st) {
          if (mounted) {
            await avisarErro(context,
                'Não foi possível apagar o modelo. Tenta de novo.', e, st);
          }
        }
      });

  @override
  Widget build(BuildContext context) {
    final consent = _tipo == 'consentimento';
    return ProtegerSaida(
      alterado: _alterado && !_aGuardar,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _existente == null
                  ? (consent ? 'Novo consentimento' : 'Novas recomendações')
                  : 'Editar modelo',
              style: fonteTitulo.copyWith(fontSize: 20)),
          actions: [
            if (_existente != null)
              IconButton(
                tooltip: 'Apagar',
                icon: const Icon(Icons.delete_outline),
                onPressed: _apagar,
              ),
          ],
        ),
        body: !_carregado
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _titulo,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome (aparece na lista)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tituloDoc,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Título do documento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _texto,
                    minLines: 14,
                    maxLines: 40,
                    decoration: const InputDecoration(
                      labelText: 'Texto',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dicas: separa os parágrafos com uma linha em branco. '
                    'Uma linha só em MAIÚSCULAS passa a título. '
                    'Podes usar {nome}, {primeiro_nome} e {data}, que são substituídos pelos dados do paciente.',
                    style: TextStyle(color: AuraCores.textoSuave, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AuraCores.rosa,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _aGuardar ? null : _guardar,
                    child: Text(_aGuardar ? 'A guardar...' : 'Guardar modelo'),
                  ),
                ],
              ),
      ),
    );
  }
}
