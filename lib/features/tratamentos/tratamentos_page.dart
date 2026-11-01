import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/documento_pdf.dart';
import '../../core/imagem_blob.dart';
import '../../core/pdf_partilhavel.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../ficha/ficha_modelo.dart' show tratamentosDe;

/// Próximo tratamento + tratamentos realizados (data, material, lote, técnica, resultado).
class TratamentosPage extends ConsumerWidget {
  const TratamentosPage({super.key, required this.id});
  final String id;

  Future<void> _novoProposto(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    var data = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Próximo tratamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Tratamento a realizar a seguir'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(DateFormat('dd/MM/yyyy').format(data)),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'PT'),
                  );
                  if (d != null) setD(() => data = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await ref.read(repoProvider).adicionarTratamentoProposto(
          id, DateFormat('dd/MM/yyyy').format(data), ctrl.text.trim());
    }
  }

  Future<void> _marcarRealizado(BuildContext context, WidgetRef ref,
      Paciente p, int i, Map<String, String> prop) async {
    DateTime? d;
    try {
      d = DateFormat('dd/MM/yyyy').parseStrict(prop['data'] ?? '');
    } catch (_) {}
    final ok = await abrirTratamentoSheet(context, p.id,
        tratamentoInicial: prop['tratamento'], dataInicial: d);
    if (ok == true) {
      await ref.read(repoProvider).removerTratamentoProposto(p.id, i);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(pacienteProvider(id)).valueOrNull;
    final ficha = ref.watch(fichaProvider(id)).valueOrNull;
    final propostos = tratamentosDe(ficha);
    final realizados =
        ref.watch(tratamentosRealizadosProvider(id)).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tratamentos', style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text('Próximo tratamento',
                    style: fonteTitulo.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                if (propostos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Ainda não escreveste o próximo tratamento.',
                        style: TextStyle(color: AuraCores.textoSuave)),
                  ),
                for (var i = 0; i < propostos.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AuraCard(
                      child: ListTile(
                        leading:
                            const Icon(Icons.event_outlined, color: AuraCores.rosa),
                        title: Text(propostos[i]['tratamento'] ?? ''),
                        subtitle: Text(propostos[i]['data'] ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'feito') {
                              await _marcarRealizado(
                                  context, ref, p, i, propostos[i]);
                            } else if (v == 'apagar') {
                              await ref
                                  .read(repoProvider)
                                  .removerTratamentoProposto(p.id, i);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'feito',
                                child: Text('Marcar como realizado')),
                            PopupMenuItem(value: 'apagar', child: Text('Apagar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _novoProposto(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Escrever próximo tratamento'),
                ),
                const SizedBox(height: 28),
                Text('Tratamentos realizados',
                    style: fonteTitulo.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraCores.rosa,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => abrirTratamentoSheet(context, p.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Registar tratamento realizado'),
                ),
                const SizedBox(height: 12),
                if (realizados.isEmpty)
                  const Text('Ainda não há tratamentos registados.',
                      style: TextStyle(color: AuraCores.textoSuave)),
                for (final t in realizados) _CartaoTratamento(t, p),
              ],
            ),
    );
  }
}

class _CartaoTratamento extends ConsumerWidget {
  const _CartaoTratamento(this.t, this.p);
  final TratamentoRealizado t;
  final Paciente p;

  Widget _linha(String r, String v) => v.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: '$r: ',
                style: const TextStyle(
                    color: AuraCores.textoSuave, fontWeight: FontWeight.w600)),
            TextSpan(text: v),
          ])),
        );

  Future<void> _partilhar(BuildContext context, WidgetRef ref) async {
    Uint8List? rotulo;
    if (t.rotuloFoto != null) {
      rotulo = await ref.read(repoProvider).lerBlob(t.rotuloFoto!);
    }
    final linhas = <String>[
      'Tratamento: ${t.tratamento}',
      if (t.material.isNotEmpty) 'Produto: ${t.material}',
      if (t.lote.isNotEmpty) 'Lote: ${t.lote}',
      if (t.tecnica.isNotEmpty) 'Técnica: ${t.tecnica}',
      if (t.resultado.isNotEmpty) 'Resultado: ${t.resultado}',
    ];
    final fmt = DateFormat('dd/MM/yyyy');
    final nome = 'Registo_${p.nome.trim().replaceAll(RegExp(r'\s+'), '_')}_'
        '${DateFormat('yyyyMMdd').format(t.data)}.pdf';
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('Registo do tratamento',
              style: fonteTitulo.copyWith(fontSize: 20)),
        ),
        body: PdfPartilhavel(
          nomeFicheiro: nome,
          assunto: 'Registo do tratamento',
          corpo: 'Segue em anexo o registo do tratamento realizado.',
          aviso:
              'Este documento refere um tratamento de saúde. Partilha apenas com a paciente e por um canal que consideres seguro.',
          gerar: () => gerarPdfDocumento(
            titulo: 'REGISTO DO TRATAMENTO',
            texto: linhas.join('\n\n'),
            cabecalho: [('Paciente', p.nome), ('Data', fmt.format(t.data))],
            imagens: rotulo == null ? const [] : [rotulo],
            rodape: 'Aura · ${p.nome} · registo do tratamento',
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AuraCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(t.data),
                          style: const TextStyle(
                              color: AuraCores.textoSuave,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(t.tratamento,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                      _linha('Material', t.material),
                      _linha('Lote', t.lote),
                      _linha('Técnica', t.tecnica),
                      _linha('Resultado', t.resultado),
                      if (t.rotuloFoto != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ImagemBlob(t.rotuloFoto!,
                              largura: 84, altura: 84, cacheWidth: 250),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'editar') {
                      await abrirTratamentoSheet(context, p.id, existente: t);
                    } else if (v == 'partilhar') {
                      await _partilhar(context, ref);
                    } else if (v == 'apagar') {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Apagar este tratamento?'),
                          content: const Text('Esta ação não pode ser desfeita.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar')),
                            FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Apagar')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(repoProvider)
                            .apagarTratamentoRealizado(t);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(
                        value: 'partilhar',
                        child: Text('Enviar registo à paciente (PDF)')),
                    PopupMenuItem(value: 'apagar', child: Text('Apagar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

/// Regista (ou edita) um tratamento realizado. Devolve true se guardou.
Future<bool?> abrirTratamentoSheet(
  BuildContext context,
  String pacienteId, {
  TratamentoRealizado? existente,
  String? tratamentoInicial,
  DateTime? dataInicial,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _TratamentoSheet(
        pacienteId: pacienteId,
        existente: existente,
        tratamentoInicial: tratamentoInicial,
        dataInicial: dataInicial,
      ),
    );

class _TratamentoSheet extends ConsumerStatefulWidget {
  const _TratamentoSheet({
    required this.pacienteId,
    this.existente,
    this.tratamentoInicial,
    this.dataInicial,
  });
  final String pacienteId;
  final TratamentoRealizado? existente;
  final String? tratamentoInicial;
  final DateTime? dataInicial;
  @override
  ConsumerState<_TratamentoSheet> createState() => _TratamentoSheetState();
}

class _TratamentoSheetState extends ConsumerState<_TratamentoSheet> {
  late final _tratamento = TextEditingController(
      text: widget.existente?.tratamento ?? widget.tratamentoInicial ?? '');
  late final _material =
      TextEditingController(text: widget.existente?.material ?? '');
  late final _lote = TextEditingController(text: widget.existente?.lote ?? '');
  late final _tecnica =
      TextEditingController(text: widget.existente?.tecnica ?? '');
  late final _resultado =
      TextEditingController(text: widget.existente?.resultado ?? '');
  late DateTime _data =
      widget.existente?.data ?? widget.dataInicial ?? DateTime.now();
  Uint8List? _novoRotulo;
  bool _removerRotulo = false;
  bool _aGuardar = false;

  @override
  void dispose() {
    for (final c in [_tratamento, _material, _lote, _tecnica, _resultado]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherRotulo() async {
    final fonte = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Fotografar o rótulo'),
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
    final x = await ImagePicker()
        .pickImage(source: fonte, maxWidth: 1600, imageQuality: 85);
    if (x == null) return;
    final b = await x.readAsBytes();
    if (mounted) {
      setState(() {
        _novoRotulo = b;
        _removerRotulo = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (_tratamento.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indica o tratamento realizado.')));
      return;
    }
    setState(() => _aGuardar = true);
    final repo = ref.read(repoProvider);
    String? chave = widget.existente?.rotuloFoto;
    if (_removerRotulo && chave != null) {
      await repo.apagarBlob(chave);
      chave = null;
    }
    if (_novoRotulo != null) {
      if (chave != null) await repo.apagarBlob(chave);
      chave = 'rotulo_${const Uuid().v4()}';
      await repo.guardarBlob(chave, _novoRotulo!);
    }
    await repo.guardarTratamentoRealizado(TratamentoRealizado(
      id: widget.existente?.id ?? const Uuid().v4(),
      pacienteId: widget.pacienteId,
      data: _data,
      tratamento: _tratamento.text.trim(),
      material: _material.text.trim(),
      lote: _lote.text.trim(),
      tecnica: _tecnica.text.trim(),
      resultado: _resultado.text.trim(),
      rotuloFoto: chave,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final modelos = ref.watch(modelosProvider('consentimento')).valueOrNull ?? [];
    final rotuloAtual = widget.existente?.rotuloFoto;
    const espaco = SizedBox(height: 12);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                widget.existente == null
                    ? 'Tratamento realizado'
                    : 'Editar tratamento',
                style: fonteTitulo.copyWith(fontSize: 24),
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _data,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('pt', 'PT'),
                );
                if (d != null) setState(() => _data = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(DateFormat('dd/MM/yyyy').format(_data)),
              ),
            ),
            espaco,
            TextField(
              controller: _tratamento,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Tratamento', border: OutlineInputBorder()),
            ),
            if (modelos.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 0,
                children: [
                  for (final m in modelos)
                    ActionChip(
                      label: Text(m.titulo, style: const TextStyle(fontSize: 12)),
                      onPressed: () =>
                          setState(() => _tratamento.text = m.titulo),
                    ),
                ],
              ),
            ],
            espaco,
            TextField(
              controller: _material,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Tipo de material / produto',
                  border: OutlineInputBorder()),
            ),
            espaco,
            TextField(
              controller: _lote,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                  labelText: 'Lote', border: OutlineInputBorder()),
            ),
            espaco,
            TextField(
              controller: _tecnica,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Técnica', border: OutlineInputBorder()),
            ),
            espaco,
            TextField(
              controller: _resultado,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Resultado',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()),
            ),
            espaco,
            Row(
              children: [
                if (_novoRotulo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_novoRotulo!,
                        width: 64, height: 64, fit: BoxFit.cover, cacheWidth: 200),
                  )
                else if (rotuloAtual != null && !_removerRotulo)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImagemBlob(rotuloAtual,
                        largura: 64, altura: 64, cacheWidth: 200),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _escolherRotulo,
                    icon: const Icon(Icons.qr_code_scanner_outlined),
                    label: Text(_novoRotulo != null ||
                            (rotuloAtual != null && !_removerRotulo)
                        ? 'Trocar foto do rótulo'
                        : 'Foto do rótulo do produto'),
                  ),
                ),
                if (_novoRotulo != null ||
                    (rotuloAtual != null && !_removerRotulo))
                  IconButton(
                    tooltip: 'Remover foto',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() {
                      _novoRotulo = null;
                      _removerRotulo = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AuraCores.rosa,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _aGuardar ? null : _guardar,
              child: Text(_aGuardar ? 'A guardar...' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
