import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'tema.dart';

/// Pré-visualização de um PDF + botão "Partilhar" (WhatsApp, e-mail...) + imprimir.
class PdfPartilhavel extends StatelessWidget {
  const PdfPartilhavel({
    super.key,
    required this.gerar,
    required this.nomeFicheiro,
    required this.assunto,
    required this.corpo,
    this.aviso =
        'Este documento contém dados de saúde. Partilha apenas com autorização do paciente e por um canal que consideres seguro.',
  });

  final Future<Uint8List> Function() gerar;
  final String nomeFicheiro;
  final String assunto;
  final String corpo;
  final String aviso;

  Future<void> _partilhar(BuildContext botaoCtx) async {
    final ok = await showDialog<bool>(
      context: botaoCtx,
      builder: (ctx) => AlertDialog(
        title: const Text('Partilhar documento'),
        content: Text(aviso),
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
    if (ok != true) return;
    final bytes = await gerar();
    final box = botaoCtx.findRenderObject() as RenderBox?;
    final zona = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    await Printing.sharePdf(
      bytes: bytes,
      filename: nomeFicheiro,
      subject: assunto,
      body: corpo,
      bounds: zona,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Builder(
              builder: (btnCtx) => SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraCores.rosa,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _partilhar(btnCtx),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Partilhar (WhatsApp, e-mail...)'),
                ),
              ),
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: (_) => gerar(),
              pdfFileName: nomeFicheiro,
              shareActionExtraSubject: assunto,
              shareActionExtraBody: corpo,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              loadingWidget: const CircularProgressIndicator(),
            ),
          ),
        ],
      );
}
