import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';
import '../../core/imagem_blob.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import 'consent_texto.dart';

class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  final _sig = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _registo = false;
  bool _comparacao = false;
  bool _divulgacao = false;
  bool _desenhando = false; // bloqueia o scroll enquanto se assina
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    _sig.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sig.dispose();
    super.dispose();
  }

  bool get _podeGuardar => _registo && _sig.isNotEmpty && !_aGuardar;

  Future<void> _guardar() async {
    setState(() => _aGuardar = true);
    final png = await _sig.toPngBytes();
    if (png == null) {
      setState(() => _aGuardar = false);
      return;
    }
    final repo = ref.read(repoProvider);
    final id = const Uuid().v4();
    final agora = DateTime.now();
    final chave = 'assinatura_$id';
    await repo.guardarBlob(chave, png);

    // Impressão digital do documento: texto + opções + data + imagem da assinatura.
    final hash = sha256.convert([
      ...utf8.encode('$versaoConsentimento|${widget.id}|$_registo|$_comparacao|'
          '$_divulgacao|${agora.toIso8601String()}|$textoConsentimento'),
      ...png,
    ]).toString();

    await repo.guardarConsentimento(Consentimento(
      id: id,
      pacienteId: widget.id,
      versaoTexto: versaoConsentimento,
      registoClinico: _registo,
      comparacaoResultados: _comparacao,
      divulgacao: _divulgacao,
      caminhoAssinatura: chave,
      hashDocumento: hash,
      assinadoEm: agora,
    ));
    if (mounted) {
      setState(() => _aGuardar = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consentimento guardado')));
    }
  }

  Future<void> _revogar(Consentimento c) async {
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar consentimento'),
        content: const Text(
            'A revogação bloqueia novas fotografias. Queres também apagar as fotografias já guardadas?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'revogar'),
              child: const Text('Só revogar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, 'apagar'),
              child: const Text('Revogar e apagar fotos')),
        ],
      ),
    );
    if (r == null) return;
    final repo = ref.read(repoProvider);
    await repo.guardarConsentimento(c.revogar(DateTime.now()));
    if (r == 'apagar') await repo.apagarFotosDe(c.pacienteId);
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(consentimentoProvider(widget.id)).valueOrNull;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Consentimento de imagens',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: c != null && c.valido
          ? _assinado(c, fmt)
          : ListView(
              physics: _desenhando ? const NeverScrollableScrollPhysics() : null,
              padding: const EdgeInsets.all(16),
              children: [
                if (c?.revogadoEm != null)
                  AuraCard(
                    color: context.destaque,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                          'O consentimento anterior foi revogado em ${fmt.format(c!.revogadoEm!)}. Para voltar a fotografar é preciso novo consentimento.'),
                    ),
                  ),
                AuraCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textoConsentimento.trim(),
                        style: const TextStyle(height: 1.4)),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _registo,
                  onChanged: (v) => setState(() => _registo = v ?? false),
                  title: const Text(finalidadeRegisto),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _comparacao,
                  onChanged: (v) => setState(() => _comparacao = v ?? false),
                  title: const Text(finalidadeComparacao),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _divulgacao,
                  onChanged: (v) => setState(() => _divulgacao = v ?? false),
                  title: const Text(finalidadeDivulgacao),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Assinatura do(a) paciente',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    TextButton.icon(
                      onPressed: _sig.clear,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpar'),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AuraCores.rosaDourado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Listener(
                    onPointerDown: (_) => setState(() => _desenhando = true),
                    onPointerUp: (_) => setState(() => _desenhando = false),
                    onPointerCancel: (_) => setState(() => _desenhando = false),
                    child: Signature(
                      controller: _sig,
                      height: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraCores.rosa,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _podeGuardar ? _guardar : null,
                  child: Text(_aGuardar ? 'A guardar...' : 'Guardar consentimento'),
                ),
                if (!_registo)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Para guardar é obrigatório aceitar o registo clínico e assinar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AuraCores.textoSuave),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _assinado(Consentimento c, DateFormat fmt) {
    Widget linha(String t, bool ok) => ListTile(
          dense: true,
          leading: Icon(ok ? Icons.check_circle : Icons.cancel_outlined,
              color: ok ? const Color(0xFF7BA37B) : AuraCores.textoSuave),
          title: Text(t),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AuraCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consentimento assinado',
                    style: fonteTitulo.copyWith(fontSize: 22)),
                const SizedBox(height: 4),
                Text('${fmt.format(c.assinadoEm)} · versão ${c.versaoTexto}'),
                const Divider(height: 24),
                linha('Registo clínico', c.registoClinico),
                linha('Comparação de resultados', c.comparacaoResultados),
                linha('Divulgação', c.divulgacao),
                const Divider(height: 24),
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                  child: ImagemBlob(c.caminhoAssinatura, fit: BoxFit.contain),
                ),
                const SizedBox(height: 8),
                Text('Código de verificação: ${(c.hashDocumento ?? '').take12}',
                    style: const TextStyle(
                        fontSize: 12, color: AuraCores.textoSuave)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _revogar(c),
          icon: const Icon(Icons.block),
          label: const Text('Revogar consentimento'),
        ),
      ],
    );
  }
}

extension on String {
  String get take12 => length <= 12 ? this : substring(0, 12);
}
