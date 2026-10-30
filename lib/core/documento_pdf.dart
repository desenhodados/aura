import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../features/consent/consent_texto.dart' show clinicaResponsavel;
import 'texto_doc.dart';

const _rosa = PdfColor.fromInt(0xFFC9788A);
const _dourado = PdfColor.fromInt(0xFFE9B08F);

/// PDF genérico para consentimentos informados e recomendações.
/// [cabecalho]: linhas "Rótulo: valor" (nome, data de nascimento, CC...).
/// Com [comAssinaturas], termina com a data e as caixas de assinatura
/// (Médico/a e Paciente/Representante legal).
/// Conteúdo de um documento: título, cabeçalho, texto e (opcional) assinaturas.
/// Usado no PDF do próprio documento e dentro do PDF da ficha do paciente.
List<pw.Widget> conteudoDocumento({
  required String titulo,
  required String texto,
  List<(String, String)> cabecalho = const [],
  DateTime? data,
  bool comAssinaturas = false,
  Uint8List? assinaturaPaciente,
  Uint8List? assinaturaMedica,
  String? codigo,
}) {
  final fmt = DateFormat('dd/MM/yyyy');
  final blocos = blocosDe(texto);

  pw.Widget caixaAssinatura(String rotulo, Uint8List? img) => pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              height: 62,
              alignment: pw.Alignment.bottomCenter,
              child: img == null
                  ? pw.SizedBox()
                  : pw.Image(pw.MemoryImage(img), fit: pw.BoxFit.contain),
            ),
            pw.Container(height: 0.6, color: PdfColors.grey700),
            pw.SizedBox(height: 3),
            pw.Text(rotulo,
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
          ],
        ),
      );

  return [
    pw.Center(
      child: pw.Text(titulo,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold)),
    ),
    pw.SizedBox(height: 10),
    for (final (r, v) in cabecalho)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$r: ',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(
                text: v.isEmpty ? '______________________' : v,
                style: const pw.TextStyle(fontSize: 10)),
          ]),
        ),
      ),
    pw.SizedBox(height: 6),
    for (final b in blocos)
      pw.Padding(
        padding: pw.EdgeInsets.only(top: ehTituloBloco(b) ? 8 : 0, bottom: 6),
        child: pw.Text(
          b,
          style: pw.TextStyle(
            fontSize: 9.5,
            lineSpacing: 2,
            fontWeight: ehTituloBloco(b) ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    if (comAssinaturas)
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 18),
          pw.Text('Data: ${data == null ? '__ / __ / ____' : fmt.format(data)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              caixaAssinatura('Assinatura do Médico/a', assinaturaMedica),
              pw.SizedBox(width: 30),
              caixaAssinatura(
                  'Assinatura do paciente/Representante legal', assinaturaPaciente),
            ],
          ),
          if (codigo != null && codigo.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Código de verificação: $codigo',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
          ],
        ],
      ),
  ];
}

/// PDF genérico para consentimentos informados e recomendações.
/// [cabecalho]: linhas "Rótulo: valor" (nome, data de nascimento, CC...).
/// Com [comAssinaturas], termina com a data e as caixas de assinatura
/// (Médico/a e Paciente/Representante legal).
Future<Uint8List> gerarPdfDocumento({
  required String titulo,
  required String texto,
  List<(String, String)> cabecalho = const [],
  DateTime? data,
  bool comAssinaturas = false,
  Uint8List? assinaturaPaciente,
  Uint8List? assinaturaMedica,
  String? codigo,
  String? rodape,
}) async {
  final doc = pw.Document(title: titulo, author: 'Aura');

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 40),
    footer: (c) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(rodape ?? 'Aura',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text('Página ${c.pageNumber}/${c.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ],
    ),
    build: (c) => [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('AURA',
              style: pw.TextStyle(fontSize: 18, letterSpacing: 5, color: _rosa)),
          pw.Text(clinicaResponsavel.startsWith('[') ? '' : clinicaResponsavel,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
      pw.Divider(color: _dourado),
      pw.SizedBox(height: 4),
      ...conteudoDocumento(
        titulo: titulo,
        texto: texto,
        cabecalho: cabecalho,
        data: data,
        comAssinaturas: comAssinaturas,
        assinaturaPaciente: assinaturaPaciente,
        assinaturaMedica: assinaturaMedica,
        codigo: codigo,
      ),
    ],
  ));

  return doc.save();
}
