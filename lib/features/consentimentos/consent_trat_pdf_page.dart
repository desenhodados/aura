import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/documento_pdf.dart';
import '../../core/pdf_partilhavel.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

/// PDF de um consentimento já assinado: ver, imprimir e partilhar.
class ConsentTratPdfPage extends ConsumerStatefulWidget {
  const ConsentTratPdfPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ConsentTratPdfPage> createState() => _ConsentTratPdfPageState();
}

class _ConsentTratPdfPageState extends ConsumerState<ConsentTratPdfPage> {
  late final Future<ConsentimentoTratamento?> _c;

  @override
  void initState() {
    super.initState();
    _c = ref.read(repoProvider).lerConsentimentoTrat(widget.id);
  }

  String _nome(ConsentimentoTratamento c) {
    String limpo(String s) => s
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9À-ÿ]+'), '_')
        .replaceAll(RegExp(r'_+$'), '');
    return 'Consentimento_${limpo(c.titulo)}_${limpo(c.nomePaciente)}_${DateFormat('yyyyMMdd').format(c.assinadoEm)}.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consentimento assinado',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: FutureBuilder<ConsentimentoTratamento?>(
        future: _c,
        builder: (context, snap) {
          final c = snap.data;
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c == null) {
            return const Center(child: Text('Consentimento não encontrado.'));
          }
          return PdfPartilhavel(
            nomeFicheiro: _nome(c),
            assunto: '${c.titulo} - consentimento informado',
            corpo: 'Segue em anexo o consentimento informado assinado.',
            gerar: () async {
              final repo = ref.read(repoProvider);
              final assP = await repo.lerBlob(c.caminhoAssinatura);
              final assM = c.caminhoAssinaturaMedica == null
                  ? null
                  : await repo.lerBlob(c.caminhoAssinaturaMedica!);
              return gerarPdfDocumento(
                titulo: c.tituloDoc,
                texto: c.texto,
                cabecalho: [
                  ('Sr./Sra', c.nomePaciente),
                  ('Data de nascimento', c.dataNascimentoTxt),
                  ('CC nº', c.ccTxt),
                ],
                data: c.assinadoEm,
                comAssinaturas: true,
                assinaturaPaciente: assP,
                assinaturaMedica: assM,
                codigo: (c.hashDocumento ?? '').length >= 16
                    ? c.hashDocumento!.substring(0, 16)
                    : null,
                rodape: 'Aura · ${c.nomePaciente} · ${c.titulo}',
              );
            },
          );
        },
      ),
    );
  }
}
