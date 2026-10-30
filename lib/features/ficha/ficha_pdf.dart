import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/documento_pdf.dart' show conteudoDocumento;
import '../../core/formatos.dart';
import '../../data/models.dart';
import '../consent/consent_texto.dart';
import 'ficha_modelo.dart';

const _rosa = PdfColor.fromInt(0xFFC9788A);
const _dourado = PdfColor.fromInt(0xFFE9B08F);

/// Consentimento de tratamento já assinado, com as imagens das assinaturas.
class ConsentimentoParaPdf {
  const ConsentimentoParaPdf(
      this.consentimento, this.assinaturaPaciente, this.assinaturaMedica);
  final ConsentimentoTratamento consentimento;
  final Uint8List? assinaturaPaciente;
  final Uint8List? assinaturaMedica;
}

class FotoPdf {
  const FotoPdf(this.legenda, this.bytes);
  final String legenda;
  final Uint8List bytes;
}

Future<Uint8List> gerarPdfFicha(
  Paciente p,
  Map<String, dynamic> dados,
  List<Map<String, String>> trat, {
  Consentimento? consent,
  Uint8List? assinatura,
  Uint8List? fotoPerfil,
  List<ConsultaObesidade> obesidade = const [],
  bool notasObesidade = false,
  List<ConsentimentoParaPdf> consentimentosTrat = const [],
  List<FotoPdf> fotos = const [],
}) async {
  final doc = pw.Document(title: 'Ficha de avaliação - ${p.nome}', author: 'Aura');
  final fmt = DateFormat('dd/MM/yyyy');
  final fmtHora = DateFormat('dd/MM/yyyy HH:mm');

  pw.Widget barra(String t) => pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 12),
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        color: _dourado,
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white)),
      );

  pw.Widget celula(String t, {bool negrito = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  pw.Widget tabela(List<Linha> linhas) => pw.Table(
        columnWidths: {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(3),
        },
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
        children: [
          for (final l in linhas)
            pw.TableRow(children: [
              celula(l.rotulo, negrito: true),
              celula(l.valor),
            ]),
        ],
      );

  final idade = idadeDe(p.dataNascimento);
  final ident = <Linha>[
    (rotulo: 'Nome', valor: p.nome),
    if (p.dataNascimento != null)
      (
        rotulo: 'Data de nascimento',
        valor: '${fmt.format(p.dataNascimento!)}'
            '${idade != null ? ' ($idade anos)' : ''}'
      ),
    if ((p.profissao ?? '').isNotEmpty)
      (rotulo: 'Profissão', valor: p.profissao!),
    if ((p.telemovel ?? '').isNotEmpty)
      (rotulo: 'Telemóvel', valor: p.telemovel!),
    if ((p.email ?? '').isNotEmpty) (rotulo: 'E-mail', valor: p.email!),
    if ((p.numeroCC ?? '').isNotEmpty)
      (rotulo: 'Cartão de Cidadão', valor: p.numeroCC!),
    if ((p.numeroUtente ?? '').isNotEmpty)
      (rotulo: 'Nº de utente', valor: p.numeroUtente!),
  ];

  String simNao(bool b) => b ? 'Sim' : 'Não';

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
    footer: (c) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Aura · ${p.nome}',
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
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('AURA',
                  style: pw.TextStyle(
                      fontSize: 22, letterSpacing: 6, color: _rosa)),
              pw.Text('Avaliação inicial · Medicina estética',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey700)),
            ],
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(fmt.format(DateTime.now()),
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
              if (fotoPerfil != null) ...[
                pw.SizedBox(width: 12),
                pw.Container(
                  width: 52,
                  height: 66,
                  child: pw.Image(pw.MemoryImage(fotoPerfil),
                      fit: pw.BoxFit.cover),
                ),
              ],
            ],
          ),
        ],
      ),
      pw.Divider(color: _dourado),
      barra('Identificação'),
      tabela(ident),
      for (final s in secoes)
        if (linhasPreenchidas(s, dados).isNotEmpty) ...[
          barra(s.titulo),
          tabela(linhasPreenchidas(s, dados)),
        ],
      if (trat.isNotEmpty) ...[
        barra('Tratamentos propostos'),
        tabela([
          for (final t in trat)
            (rotulo: t['data'] ?? '', valor: t['tratamento'] ?? ''),
        ]),
      ],
      if (obesidade.isNotEmpty) ...[
        barra('Consultas de obesidade'),
        pw.Table(
          columnWidths: {
            0: pw.FlexColumnWidth(1.6),
            1: pw.FlexColumnWidth(1.2),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(2.4),
            4: pw.FlexColumnWidth(1.4),
          },
          border: pw.TableBorder(
            horizontalInside:
                pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          ),
          children: [
            pw.TableRow(children: [
              celula('Data', negrito: true),
              celula('Peso', negrito: true),
              celula('Altura', negrito: true),
              celula('IMC', negrito: true),
              celula('Variação', negrito: true),
            ]),
            for (var i = 0; i < obesidade.length; i++)
              pw.TableRow(children: [
                celula(fmt.format(obesidade[i].data)),
                celula('${fmtNum(obesidade[i].peso)} kg'),
                celula('${fmtNum(obesidade[i].alturaCm, casas: 0)} cm'),
                celula(
                    '${fmtNum(obesidade[i].imc)} (${classificarImc(obesidade[i].imc)})'),
                celula(i == 0
                    ? '-'
                    : '${fmtNum(obesidade[i].peso - obesidade[i - 1].peso)} kg'),
              ]),
          ],
        ),
        if (notasObesidade)
          for (final c in obesidade)
            if (c.notas.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text('${fmt.format(c.data)}: ${c.notas}',
                    style: const pw.TextStyle(fontSize: 9)),
              ),
      ],
      if (fotos.isNotEmpty) ...[
        barra('Fotografias'),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final f in fotos)
              pw.SizedBox(
                width: 255,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      height: 300,
                      width: 255,
                      color: PdfColors.grey100,
                      alignment: pw.Alignment.center,
                      child: pw.Image(pw.MemoryImage(f.bytes),
                          fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(f.legenda,
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
              ),
          ],
        ),
      ],
      if (consent != null) ...[
        barra('Consentimento para recolha de imagens'),
        pw.SizedBox(height: 6),
        pw.Text(textoConsentimento.trim(),
            style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.5)),
        pw.SizedBox(height: 6),
        tabela([
          (rotulo: 'Registo clínico', valor: simNao(consent.registoClinico)),
          (
            rotulo: 'Comparação de resultados',
            valor: simNao(consent.comparacaoResultados)
          ),
          (rotulo: 'Divulgação', valor: simNao(consent.divulgacao)),
          (rotulo: 'Assinado em', valor: fmtHora.format(consent.assinadoEm)),
          (rotulo: 'Versão do texto', valor: consent.versaoTexto),
          if (consent.revogadoEm != null)
            (rotulo: 'Revogado em', valor: fmtHora.format(consent.revogadoEm!)),
          if ((consent.hashDocumento ?? '').isNotEmpty)
            (
              rotulo: 'Código de verificação',
              valor: consent.hashDocumento!.substring(0, 16)
            ),
        ]),
        if (assinatura != null) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            height: 70,
            alignment: pw.Alignment.centerLeft,
            child: pw.Image(pw.MemoryImage(assinatura), fit: pw.BoxFit.contain),
          ),
          pw.Container(width: 220, height: 0.5, color: PdfColors.grey700),
          pw.Text('Assinatura do(a) paciente',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
      ],
      for (final x in consentimentosTrat) ...[
        pw.NewPage(),
        ...conteudoDocumento(
          titulo: x.consentimento.tituloDoc,
          texto: x.consentimento.texto,
          cabecalho: [
            ('Sr./Sra', x.consentimento.nomePaciente),
            ('Data de nascimento', x.consentimento.dataNascimentoTxt),
            ('CC nº', x.consentimento.ccTxt),
          ],
          data: x.consentimento.assinadoEm,
          comAssinaturas: true,
          assinaturaPaciente: x.assinaturaPaciente,
          assinaturaMedica: x.assinaturaMedica,
          codigo: (x.consentimento.hashDocumento ?? '').length >= 16
              ? x.consentimento.hashDocumento!.substring(0, 16)
              : null,
        ),
      ],
    ],
  ));

  return doc.save();
}
