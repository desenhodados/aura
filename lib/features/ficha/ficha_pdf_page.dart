import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../fotos/fotos_page.dart' show legendaFoto;
import 'ficha_modelo.dart';
import 'ficha_pdf.dart';

/// Pré-visualização do PDF: imprimir, guardar e partilhar (WhatsApp, e-mail, etc.).
class FichaPdfPage extends ConsumerStatefulWidget {
  const FichaPdfPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<FichaPdfPage> createState() => _FichaPdfPageState();
}

class _FichaPdfPageState extends ConsumerState<FichaPdfPage> {
  bool _incluirFotos = true;
  bool _notasObesidade = false;
  bool _incluirConsTrat = true;

  String _nomeFicheiro(Paciente p) =>
      'Ficha_${p.nome.trim().replaceAll(RegExp(r'\s+'), '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

  Future<Uint8List> _gerar(Paciente p, Ficha? f, Consentimento? c,
      List<Foto> fotos, bool comFotos) async {
    final repo = ref.read(repoProvider);
    final assinatura =
        c == null ? null : await repo.lerBlob(c.caminhoAssinatura);
    final perfil = (comFotos && p.fotoPerfil != null)
        ? await repo.lerBlob(p.fotoPerfil!)
        : null;
    final obesidade =
        await ref.read(repoProvider).consultasObesidade(p.id).first;
    final consTrat = _incluirConsTrat
        ? (await repo.consentimentosTrat(p.id).first).toList()
        : <ConsentimentoTratamento>[];
    consTrat.sort((a, b) => a.assinadoEm.compareTo(b.assinadoEm));
    final consPdf = <ConsentimentoParaPdf>[];
    for (final x in consTrat) {
      final assP = await repo.lerBlob(x.caminhoAssinatura);
      final assM = x.caminhoAssinaturaMedica == null
          ? null
          : await repo.lerBlob(x.caminhoAssinaturaMedica!);
      consPdf.add(ConsentimentoParaPdf(x, assP, assM));
    }
    final lista = <FotoPdf>[];
    if (comFotos) {
      for (final ft in fotos) {
        final b = await repo.lerBlob(ft.caminho);
        if (b != null) lista.add(FotoPdf(legendaFoto(ft), b));
      }
    }
    return gerarPdfFicha(
      p,
      dadosDe(f),
      tratamentosDe(f),
      consent: c,
      assinatura: assinatura,
      fotoPerfil: perfil,
      obesidade: obesidade,
      notasObesidade: _notasObesidade,
      consentimentosTrat: consPdf,
      fotos: lista,
    );
  }

  Future<void> _partilhar(BuildContext botaoCtx, Paciente p, Ficha? f,
      Consentimento? c, List<Foto> fotos, bool comFotos) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Partilhar ficha'),
        content: Text(
          'Esta ficha contém dados de saúde${comFotos ? ' e fotografias' : ''}. '
          'Partilha apenas com autorização do paciente e por um canal que consideres seguro.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final bytes = await _gerar(p, f, c, fotos, comFotos);

    // No iPad a folha de partilha precisa de saber de onde "sai".
    final box = botaoCtx.findRenderObject() as RenderBox?;
    final zona = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    await Printing.sharePdf(
      bytes: bytes,
      filename: _nomeFicheiro(p),
      subject: 'Ficha de avaliação - ${p.nome}',
      body: 'Segue em anexo a ficha de avaliação.',
      bounds: zona,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(pacienteProvider(widget.id)).valueOrNull;
    final f = ref.watch(fichaProvider(widget.id)).valueOrNull;
    final c = ref.watch(consentimentoProvider(widget.id)).valueOrNull;
    final fotos = ref.watch(fotosProvider(widget.id)).valueOrNull ?? [];
    final podeFotos =
        (c?.valido ?? false) && (fotos.isNotEmpty || p?.fotoPerfil != null);
    final comFotos = podeFotos && _incluirFotos;
    final temNotasOb = (ref.watch(consultasObesidadeProvider(widget.id)).valueOrNull ?? [])
        .any((c) => c.notas.isNotEmpty);

    final nConsTrat =
        (ref.watch(consentimentosTratProvider(widget.id)).valueOrNull ?? []).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF da ficha', style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (podeFotos)
                  SwitchListTile(
                    dense: true,
                    title: Text('Incluir fotografias (${fotos.length + (p.fotoPerfil != null ? 1 : 0)})'),
                    value: _incluirFotos,
                    onChanged: (v) => setState(() => _incluirFotos = v),
                  ),
                if (nConsTrat > 0)
                  SwitchListTile(
                    dense: true,
                    title: Text('Incluir consentimentos de tratamento ($nConsTrat)'),
                    subtitle: const Text('Com texto completo e assinaturas.'),
                    value: _incluirConsTrat,
                    onChanged: (v) => setState(() => _incluirConsTrat = v),
                  ),
                if (temNotasOb)
                  SwitchListTile(
                    dense: true,
                    title: const Text('Incluir notas das consultas de obesidade'),
                    subtitle: const Text('São notas pessoais: por defeito ficam de fora.'),
                    value: _notasObesidade,
                    onChanged: (v) => setState(() => _notasObesidade = v),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Builder(
                    builder: (btnCtx) => SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AuraCores.rosa,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            _partilhar(btnCtx, p, f, c, fotos, comFotos),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Partilhar (WhatsApp, e-mail...)'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: (_) => _gerar(p, f, c, fotos, comFotos),
                    pdfFileName: _nomeFicheiro(p),
                    shareActionExtraSubject: 'Ficha de avaliação - ${p.nome}',
                    shareActionExtraBody: 'Segue em anexo a ficha de avaliação.',
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    loadingWidget: const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
    );
  }
}
