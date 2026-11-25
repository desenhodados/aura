import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/interacao.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

/// Formata o nº do Cartão de Cidadão como "11111111 1 ZX1":
/// dígitos do documento, dígito de controlo, e 2 letras + 1 dígito.
/// Devolve null se não tiver este formato.
String? normalizarCC(String texto) {
  final t = texto.toUpperCase().replaceAll(' ', '');
  final m = RegExp(r'^(\d{8,9})(\d)([A-Z]{2}\d)$').firstMatch(t);
  return m == null ? null : '${m[1]} ${m[2]} ${m[3]}';
}

/// Só deixa escrever dígitos, letras maiúsculas e espaços.
class _FormatoCC extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue antigo, TextEditingValue novo) {
    var t = novo.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^0-9A-Z ]'), '')
        .replaceAll(RegExp(r' +'), ' ');
    if (t.startsWith(' ')) t = t.substring(1);
    if (t.length > 15) t = t.substring(0, 15);
    final pos = novo.selection.baseOffset.clamp(0, t.length);
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: pos),
    );
  }
}

/// Abre a identificação (nova ficha, ou edição se [paciente] for dado).
/// Devolve o id do paciente guardado.
Future<String?> abrirIdentificacao(BuildContext context,
        {Paciente? paciente}) =>
    abrirFolhaFormulario<String>(
        context, (_) => NovaFichaSheet(paciente: paciente));

/// Identificação: nome, data de nascimento, profissão, telemóvel, e-mail,
/// nº de cartão de cidadão e nº de utente.
class NovaFichaSheet extends ConsumerStatefulWidget {
  const NovaFichaSheet({super.key, this.paciente});
  final Paciente? paciente;
  @override
  ConsumerState<NovaFichaSheet> createState() => _NovaFichaSheetState();
}

class _NovaFichaSheetState extends ConsumerState<NovaFichaSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _profissao;
  late final TextEditingController _telemovel;
  late final TextEditingController _email;
  late final TextEditingController _cc;
  late final TextEditingController _utente;
  DateTime? _nascimento;
  late final String _original;
  bool _aGuardar = false;

  /// Retrato do que está escrito, para saber se houve alterações.
  String _estado() => [
        for (final c in [_nome, _profissao, _telemovel, _email, _cc, _utente])
          c.text.trim(),
        _nascimento?.toIso8601String() ?? '',
      ].join('|');

  bool get _alterado => _estado() != _original;

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    _nome = TextEditingController(text: p?.nome ?? '');
    _profissao = TextEditingController(text: p?.profissao ?? '');
    _telemovel = TextEditingController(text: p?.telemovel ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _cc = TextEditingController(text: p?.numeroCC ?? '');
    _utente = TextEditingController(text: p?.numeroUtente ?? '');
    _nascimento = p?.dataNascimento;
    _original = _estado();
  }

  @override
  void dispose() {
    for (final c in [_nome, _profissao, _telemovel, _email, _cc, _utente]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _v(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? DateTime(hoje.year - 35),
      firstDate: DateTime(1900),
      lastDate: hoje,
      locale: const Locale('pt', 'PT'),
    );
    if (d != null) setState(() => _nascimento = d);
  }

  Future<void> _guardar() async {
    if (_aGuardar || !_form.currentState!.validate()) return;
    setState(() => _aGuardar = true);
    try {
      await _gravar();
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _aGuardar = false);
      await avisarErro(context,
          'Não foi possível guardar a identificação. Tenta de novo.', e, st);
    }
  }

  Future<void> _gravar() async {
    final repo = ref.read(repoProvider);
    final existente = widget.paciente;
    final Paciente p;
    if (existente != null) {
      p = existente.editar(
        nome: _nome.text.trim(),
        dataNascimento: _nascimento,
        profissao: _v(_profissao),
        telemovel: _v(_telemovel),
        email: _v(_email),
        numeroCC: normalizarCC(_cc.text) ?? _v(_cc),
        numeroUtente: _v(_utente),
      );
    } else {
      p = Paciente(
        id: const Uuid().v4(),
        nome: _nome.text.trim(),
        dataNascimento: _nascimento,
        profissao: _v(_profissao),
        telemovel: _v(_telemovel),
        email: _v(_email),
        numeroCC: normalizarCC(_cc.text) ?? _v(_cc),
        numeroUtente: _v(_utente),
        criadoEm: DateTime.now(),
      );
    }
    await repo.guardarPaciente(p);
    if (mounted) Navigator.of(context).pop(p.id);
  }

  @override
  Widget build(BuildContext context) {
    final editar = widget.paciente != null;
    const espaco = SizedBox(height: 12);
    return ProtegerSaida(
      alterado: _alterado && !_aGuardar,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            12, 0, 12, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _form,
            onChanged: () => setState(() {}),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloFolha(editar ? 'Editar identificação' : 'Nova ficha',
                    subtitulo: 'Identificação'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Nome', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Indica o nome' : null,
                ),
                espaco,
                InkWell(
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Data de nascimento',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined)),
                    child: Text(_nascimento == null
                        ? 'Selecionar'
                        : DateFormat('dd/MM/yyyy').format(_nascimento!)),
                  ),
                ),
                espaco,
                TextFormField(
                  controller: _cc,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_FormatoCC()],
                  decoration: const InputDecoration(
                    labelText: 'Nº do Cartão de Cidadão',
                    hintText: '11111111 1 ZX1',
                    helperText:
                        'Dígitos, dígito de controlo e letras: 11111111 1 ZX1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    return normalizarCC(s) == null
                        ? 'Formato: 11111111 1 ZX1'
                        : null;
                  },
                ),
                espaco,
                TextFormField(
                  controller: _utente,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Nº de utente (SNS)',
                      border: OutlineInputBorder()),
                ),
                espaco,
                TextFormField(
                  controller: _profissao,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Profissão', border: OutlineInputBorder()),
                ),
                espaco,
                TextFormField(
                  controller: _telemovel,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Telemóvel', border: OutlineInputBorder()),
                ),
                espaco,
                TextFormField(
                  controller: _email,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'E-mail', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraCores.rosa,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _aGuardar ? null : _guardar,
                  child: Text(_aGuardar
                      ? 'A guardar...'
                      : (editar ? 'Guardar' : 'Criar ficha')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
