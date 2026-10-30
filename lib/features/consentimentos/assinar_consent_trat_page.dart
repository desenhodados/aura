import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';
import '../../core/imagem_blob.dart';
import '../../core/providers.dart';
import '../../core/texto_doc.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

/// Mostra o consentimento de um tratamento e recolhe a assinatura do paciente.
class AssinarConsentTratPage extends ConsumerStatefulWidget {
  const AssinarConsentTratPage(
      {super.key, required this.pacienteId, required this.modeloId});
  final String pacienteId;
  final String modeloId;
  @override
  ConsumerState<AssinarConsentTratPage> createState() =>
      _AssinarConsentTratPageState();
}

class _AssinarConsentTratPageState extends ConsumerState<AssinarConsentTratPage> {
  final _sig = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  late final Future<Modelo?> _modelo;
  bool _aceito = false;
  bool _desenhando = false;
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    _modelo = ref.read(repoProvider).lerModelo(widget.modeloId);
    _sig.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sig.dispose();
    super.dispose();
  }

  Future<void> _guardar(Modelo m, Paciente p) async {
    setState(() => _aGuardar = true);
    final png = await _sig.toPngBytes();
    if (png == null) {
      setState(() => _aGuardar = false);
      return;
    }
    final repo = ref.read(repoProvider);
    final id = const Uuid().v4();
    final agora = DateTime.now();

    await repo.guardarBlob('assinatura_ct_$id', png);

    // copia a assinatura da médica para este documento (fica "congelada")
    String? chaveMedica;
    final atualMedica = repo.chaveAssinaturaMedica;
    if (atualMedica != null) {
      final bytes = await repo.lerBlob(atualMedica);
      if (bytes != null) {
        chaveMedica = 'assinatura_med_ct_$id';
        await repo.guardarBlob(chaveMedica, bytes);
      }
    }

    final texto = substituirMarcadores(m.texto, p, agora);
    final dn = p.dataNascimento == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(p.dataNascimento!);
    final cc = (p.numeroCC ?? '').trim();

    final hash = sha256.convert([
      ...utf8.encode('${m.tituloDoc}|$texto|${p.nome}|$dn|$cc|${agora.toIso8601String()}'),
      ...png,
    ]).toString();

    await repo.guardarConsentimentoTrat(ConsentimentoTratamento(
      id: id,
      pacienteId: p.id,
      modeloId: m.id,
      titulo: m.titulo,
      tituloDoc: m.tituloDoc,
      texto: texto,
      nomePaciente: p.nome,
      dataNascimentoTxt: dn,
      ccTxt: cc,
      assinadoEm: agora,
      caminhoAssinatura: 'assinatura_ct_$id',
      caminhoAssinaturaMedica: chaveMedica,
      hashDocumento: hash,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consentimento assinado e guardado')));
      context.pushReplacement('/consentimento-trat/$id/pdf');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(pacienteProvider(widget.pacienteId)).valueOrNull;
    final chaveMedica = ref.watch(assinaturaMedicaProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Consentimento informado',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: FutureBuilder<Modelo?>(
        future: _modelo,
        builder: (context, snap) {
          final m = snap.data;
          if (snap.connectionState != ConnectionState.done || p == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (m == null) {
            return const Center(child: Text('Modelo não encontrado.'));
          }
          final hoje = DateTime.now();
          final texto = substituirMarcadores(m.texto, p, hoje);
          final dn = p.dataNascimento == null
              ? '______________'
              : DateFormat('dd/MM/yyyy').format(p.dataNascimento!);
          final cc = (p.numeroCC ?? '').trim().isEmpty
              ? '______________'
              : p.numeroCC!.trim();

          return ListView(
            physics: _desenhando ? const NeverScrollableScrollPhysics() : null,
            padding: const EdgeInsets.all(16),
            children: [
              Text(m.tituloDoc,
                  textAlign: TextAlign.center,
                  style: fonteTitulo.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              AuraCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sr./Sra: ${p.nome}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Data de nascimento: $dn'),
                      Text('CC nº: $cc'),
                      if ((p.numeroCC ?? '').trim().isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Falta o nº de CC: voltar e editar a identificação'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuraCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextoDocumento(texto),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _aceito,
                onChanged: (v) => setState(() => _aceito = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                    'Li e compreendi este documento, pude esclarecer as minhas dúvidas e dou o meu consentimento.'),
              ),
              const SizedBox(height: 8),
              Text('Data: ${DateFormat('dd/MM/yyyy').format(hoje)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text('Assinatura do paciente/Representante legal',
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
              const SizedBox(height: 12),
              const Text('Assinatura do Médico/a',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF3DACB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: chaveMedica == null
                    ? const Center(
                        child: Text('Sem assinatura guardada (ficará em branco no PDF)',
                            style: TextStyle(color: AuraCores.textoSuave)))
                    : ImagemBlob(chaveMedica, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AuraCores.rosa,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: (_aceito && _sig.isNotEmpty && !_aGuardar)
                    ? () => _guardar(m, p)
                    : null,
                child: Text(_aGuardar ? 'A guardar...' : 'Assinar e guardar'),
              ),
              if (!_aceito || _sig.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Para guardar: marca a declaração e assina.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AuraCores.textoSuave),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
