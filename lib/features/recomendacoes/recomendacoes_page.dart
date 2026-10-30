import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/contactos.dart';
import '../../core/documento_pdf.dart';
import '../../core/formatos.dart';
import '../../core/pdf_partilhavel.dart';
import '../../core/providers.dart';
import '../../core/texto_doc.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../consent/consent_texto.dart' show clinicaResponsavel;

/// No fim da consulta: escolhe o tratamento, ajusta o texto e envia por
/// WhatsApp, e-mail ou PDF.
class RecomendacoesPage extends ConsumerStatefulWidget {
  const RecomendacoesPage({super.key, required this.pacienteId});
  final String pacienteId;
  @override
  ConsumerState<RecomendacoesPage> createState() => _RecomendacoesPageState();
}

class _RecomendacoesPageState extends ConsumerState<RecomendacoesPage> {
  static const _livre = '_livre';
  static const _tituloGenerico = 'RECOMENDAÇÕES PÓS-TRATAMENTO';
  final _texto = TextEditingController();
  String? _sel;
  String _tituloDoc = _tituloGenerico;

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _escolher(Modelo? m, Paciente p) {
    setState(() {
      _sel = m?.id ?? _livre;
      _tituloDoc = m?.tituloDoc ?? _tituloGenerico;
      _texto.text =
          m == null ? '' : substituirMarcadores(m.texto, p, DateTime.now());
    });
  }

  bool get _pronto => _sel != null && _texto.text.trim().isNotEmpty;

  String get _assinatura =>
      clinicaResponsavel.startsWith('[') ? '' : '\n\n$clinicaResponsavel';

  String _paraWhatsApp(Paciente p) {
    final corpo = blocosDe(_texto.text)
        .map((b) => ehTituloBloco(b) ? '*$b*' : b)
        .join('\n\n');
    return 'Olá ${primeiroNome(p.nome)},\n\n*$_tituloDoc*\n\n$corpo\n\n'
        'Qualquer dúvida, estou ao dispor.$_assinatura';
  }

  String _paraEmail(Paciente p) {
    final corpo = blocosDe(_texto.text).join('\n\n');
    return 'Olá ${primeiroNome(p.nome)},\n\n$corpo\n\n'
        'Qualquer dúvida, estou ao dispor.\n\nCom os melhores cumprimentos,$_assinatura';
  }

  void _aviso(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _whatsApp(Paciente p) async {
    try {
      final ok = await abrirWhatsApp(p.telemovel, _paraWhatsApp(p));
      if (!ok) _aviso('Não foi possível abrir o WhatsApp.');
    } catch (_) {
      _aviso('Não foi possível abrir o WhatsApp.');
    }
  }

  Future<void> _email(Paciente p) async {
    try {
      final ok =
          await abrirEmail(p.email, 'Recomendações pós-tratamento', _paraEmail(p));
      if (!ok) _aviso('Não foi possível abrir a aplicação de e-mail.');
    } catch (_) {
      _aviso('Não foi possível abrir a aplicação de e-mail.');
    }
  }

  void _pdf(Paciente p) {
    final hoje = DateTime.now();
    final texto = _texto.text.trim();
    final titulo = _tituloDoc;
    final nome = 'Recomendacoes_${p.nome.trim().replaceAll(RegExp(r'\s+'), '_')}_'
        '${DateFormat('yyyyMMdd').format(hoje)}.pdf';
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('PDF das recomendações',
              style: fonteTitulo.copyWith(fontSize: 20)),
        ),
        body: PdfPartilhavel(
          nomeFicheiro: nome,
          assunto: 'Recomendações pós-tratamento',
          corpo: 'Segue em anexo as recomendações pós-tratamento.',
          aviso:
              'Este documento refere um tratamento de saúde. Partilha apenas com a paciente e por um canal que consideres seguro.',
          gerar: () => gerarPdfDocumento(
            titulo: titulo,
            texto: texto,
            cabecalho: [
              ('Paciente', p.nome),
              ('Data', DateFormat('dd/MM/yyyy').format(hoje)),
            ],
            rodape: 'Aura · ${p.nome} · recomendações pós-tratamento',
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(pacienteProvider(widget.pacienteId)).valueOrNull;
    final modelos = ref.watch(modelosProvider('recomendacao')).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendações pós-tratamento',
            style: fonteTitulo.copyWith(fontSize: 19)),
        actions: [
          IconButton(
            tooltip: 'Editar modelos',
            icon: const Icon(Icons.description_outlined),
            onPressed: () => context.push('/modelos'),
          ),
        ],
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text('Para: ${p.nome}',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  [
                    if ((p.telemovel ?? '').isNotEmpty) 'Tel. ${p.telemovel}',
                    if ((p.email ?? '').isNotEmpty) p.email!,
                  ].isEmpty
                      ? 'Sem telemóvel nem e-mail registados: escolhes o contacto na própria aplicação.'
                      : [
                          if ((p.telemovel ?? '').isNotEmpty)
                            'Tel. ${p.telemovel}',
                          if ((p.email ?? '').isNotEmpty) p.email!,
                        ].join(' · '),
                  style: const TextStyle(color: AuraCores.textoSuave),
                ),
                const SizedBox(height: 16),
                const Text('Tratamento',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in modelos)
                      ChoiceChip(
                        label: Text(m.titulo),
                        selected: _sel == m.id,
                        onSelected: (_) => _escolher(m, p),
                      ),
                    ChoiceChip(
                      label: const Text('Texto livre'),
                      selected: _sel == _livre,
                      onSelected: (_) => _escolher(null, p),
                    ),
                  ],
                ),
                if (_sel != null) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _texto,
                    minLines: 12,
                    maxLines: 30,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Texto a enviar (podes ajustar)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E9E5B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _pronto ? () => _whatsApp(p) : null,
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Enviar por WhatsApp'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _pronto ? () => _email(p) : null,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Enviar por e-mail'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _pronto ? () => _pdf(p) : null,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Gerar PDF (anexar / imprimir)'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'O WhatsApp e o e-mail abrem com a mensagem já escrita; só tens de carregar em enviar. '
                    'Para enviar o PDF como anexo, usa "Gerar PDF" e depois "Partilhar".',
                    style: TextStyle(color: AuraCores.textoSuave, fontSize: 13),
                  ),
                ],
              ],
            ),
    );
  }
}
