import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/imagem_blob.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import 'editar_foto_page.dart';

const _angulos = [
  'Frontal',
  'Perfil direito',
  'Perfil esquerdo',
  '3/4 direito',
  '3/4 esquerdo',
  'Corpo',
  'Outro',
];

String legendaFoto(Foto f) =>
    '${toBeginningOfSentenceCase(f.momento)} · ${f.angulo ?? 'Foto'} · '
    '${DateFormat('dd/MM/yyyy').format(f.tiradaEm)}';

class FotosPage extends ConsumerStatefulWidget {
  const FotosPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<FotosPage> createState() => _FotosPageState();
}

class _FotosPageState extends ConsumerState<FotosPage>
    with SingleTickerProviderStateMixin {
  // Duas "pastas": separador 0 = Antes, separador 1 = Depois.
  late final TabController _tab = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (mounted) setState(() {});
    });

  String get _momentoAtual => _tab.index == 0 ? 'antes' : 'depois';

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _adicionar() async {
    final momento = _momentoAtual; // a foto vai para a pasta que está aberta
    final fonte = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar fotografia'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (fonte == null) return;

    // 1600 px de lado maior mantém boa qualidade e ficheiros leves (PDF também).
    final x = await ImagePicker()
        .pickImage(source: fonte, maxWidth: 1600, imageQuality: 85);
    if (x == null || !mounted) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;

    final meta = await showModalBottomSheet<_Meta>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _MetaSheet(bytes: bytes, momentoInicial: momento),
    );
    if (meta == null) return;

    final repo = ref.read(repoProvider);
    final id = const Uuid().v4();
    final chave = 'foto_$id';
    await repo.guardarBlob(chave, bytes);
    await repo.guardarFoto(Foto(
      id: id,
      pacienteId: widget.id,
      caminho: chave,
      angulo: meta.angulo,
      momento: meta.momento,
      tiradaEm: DateTime.now(),
    ));
    // mostra a pasta onde a foto ficou
    if (mounted) _tab.animateTo(meta.momento == 'antes' ? 0 : 1);
  }

  Future<void> _ver(Foto f) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(legendaFoto(f), style: const TextStyle(fontSize: 15)),
            actions: [
              IconButton(
                tooltip: 'Editar: riscar e sublinhar',
                icon: const Icon(Icons.draw_outlined),
                onPressed: () async {
                  final gravou = await Navigator.of(ctx).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => EditarFotoPage(foto: f)),
                  );
                  if (gravou == true && ctx.mounted) Navigator.pop(ctx);
                },
              ),
              IconButton(
                tooltip: f.momento == 'antes'
                    ? 'Mover para DEPOIS'
                    : 'Mover para ANTES',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () async {
                  await ref.read(repoProvider).guardarFoto(Foto(
                        id: f.id,
                        pacienteId: f.pacienteId,
                        consultaId: f.consultaId,
                        caminho: f.caminho,
                        angulo: f.angulo,
                        momento: f.momento == 'antes' ? 'depois' : 'antes',
                        tiradaEm: f.tiradaEm,
                      ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: ctx,
                    builder: (c2) => AlertDialog(
                      title: const Text('Apagar fotografia?'),
                      content: const Text('Esta ação não pode ser desfeita.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c2, false),
                            child: const Text('Cancelar')),
                        FilledButton(
                            onPressed: () => Navigator.pop(c2, true),
                            child: const Text('Apagar')),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await ref.read(repoProvider).apagarFoto(f);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
          body: InteractiveViewer(
            maxScale: 5,
            child: Center(
              child: ImagemBlob(f.caminho, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grade(List<Foto> fotos, String momento) {
    if (fotos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Ainda não há fotografias em "${toBeginningOfSentenceCase(momento)}".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuraCores.textoSuave),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: fotos.length,
      itemBuilder: (_, i) {
        final f = fotos[i];
        return GestureDetector(
          onTap: () => _ver(f),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImagemBlob(f.caminho, cacheWidth: 400),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black54,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '${f.angulo ?? ''} · ${DateFormat('dd/MM/yy').format(f.tiradaEm)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final consent = ref.watch(consentimentoProvider(widget.id)).valueOrNull;
    final todas = ref.watch(fotosProvider(widget.id)).valueOrNull ?? [];
    final valido = consent?.valido ?? false;
    final antes = todas.where((f) => f.momento == 'antes').toList();
    final depois = todas.where((f) => f.momento == 'depois').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fotografias', style: fonteTitulo.copyWith(fontSize: 20)),
        actions: [
          if (todas.length >= 2)
            IconButton(
              tooltip: 'Comparar',
              icon: const Icon(Icons.compare),
              onPressed: () => context.push('/paciente/${widget.id}/comparar'),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AuraCores.texto,
          indicatorColor: AuraCores.rosa,
          tabs: [
            Tab(icon: const Icon(Icons.folder_outlined), text: 'Antes (${antes.length})'),
            Tab(icon: const Icon(Icons.folder_special_outlined), text: 'Depois (${depois.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!valido)
            AuraCard(
              margin: const EdgeInsets.all(16),
              color: context.destaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                        'Para tirar fotografias é preciso o consentimento assinado.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AuraCores.rosa),
                      onPressed: () =>
                          context.push('/paciente/${widget.id}/consent'),
                      child: const Text('Assinar consentimento'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_grade(antes, 'antes'), _grade(depois, 'depois')],
            ),
          ),
        ],
      ),
      floatingActionButton: valido
          ? FloatingActionButton.extended(
              backgroundColor: AuraCores.rosa,
              foregroundColor: Colors.white,
              onPressed: _adicionar,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(_tab.index == 0 ? 'Foto de ANTES' : 'Foto de DEPOIS'),
            )
          : null,
    );
  }
}

class _Meta {
  const _Meta(this.angulo, this.momento);
  final String angulo;
  final String momento;
}

class _MetaSheet extends StatefulWidget {
  const _MetaSheet({required this.bytes, required this.momentoInicial});
  final Uint8List bytes;
  final String momentoInicial;
  @override
  State<_MetaSheet> createState() => _MetaSheetState();
}

class _MetaSheetState extends State<_MetaSheet> {
  String _angulo = _angulos.first;
  late String _momento = widget.momentoInicial;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(widget.bytes,
                        width: 90, height: 90, fit: BoxFit.cover, cacheWidth: 300),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Detalhes da fotografia',
                        style: fonteTitulo.copyWith(fontSize: 22)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'antes', label: Text('ANTES')),
                  ButtonSegment(value: 'depois', label: Text('DEPOIS')),
                ],
                selected: {_momento},
                onSelectionChanged: (s) => setState(() => _momento = s.first),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _angulos
                    .map((a) => ChoiceChip(
                          label: Text(a),
                          selected: _angulo == a,
                          onSelected: (_) => setState(() => _angulo = a),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AuraCores.rosa,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.pop(context, _Meta(_angulo, _momento)),
                child: Text('Guardar em ${_momento.toUpperCase()}'),
              ),
            ],
          ),
        ),
      );
}
