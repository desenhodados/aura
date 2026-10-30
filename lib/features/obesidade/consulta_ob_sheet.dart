import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/formatos.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

/// Nova consulta (ou edição): data, peso, altura, IMC automático e notas.
class ConsultaObSheet extends ConsumerStatefulWidget {
  const ConsultaObSheet({
    super.key,
    required this.pacienteId,
    this.existente,
    this.alturaAnterior,
  });
  final String pacienteId;
  final ConsultaObesidade? existente;

  /// Altura da consulta anterior (cm), para vir já preenchida.
  final double? alturaAnterior;

  @override
  ConsumerState<ConsultaObSheet> createState() => _ConsultaObSheetState();
}

class _ConsultaObSheetState extends ConsumerState<ConsultaObSheet> {
  late final TextEditingController _peso;
  late final TextEditingController _altura;
  late final TextEditingController _notas;
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _data = e?.data ?? DateTime.now();
    _peso = TextEditingController(text: e == null ? '' : fmtNum(e.peso));
    final alt = e?.alturaCm ?? widget.alturaAnterior;
    _altura = TextEditingController(
        text: alt == null ? '' : fmtNum(alt, casas: alt == alt.roundToDouble() ? 0 : 1));
    _notas = TextEditingController(text: e?.notas ?? '');
    _peso.addListener(() => setState(() {}));
    _altura.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _peso.dispose();
    _altura.dispose();
    _notas.dispose();
    super.dispose();
  }

  double? get _pesoKg {
    final v = lerNum(_peso.text);
    return (v != null && v >= 20 && v <= 400) ? v : null;
  }

  /// Aceita centímetros (165) ou metros (1,65).
  double? get _alturaCm {
    var v = lerNum(_altura.text);
    if (v == null) return null;
    if (v < 3) v = v * 100;
    return (v >= 100 && v <= 250) ? v : null;
  }

  double? get _imc {
    final p = _pesoKg, a = _alturaCm;
    if (p == null || a == null) return null;
    final m = a / 100;
    return p / (m * m);
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'PT'),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _guardar() async {
    final p = _pesoKg, a = _alturaCm;
    if (p == null || a == null) return;
    final c = ConsultaObesidade(
      id: widget.existente?.id ?? const Uuid().v4(),
      pacienteId: widget.pacienteId,
      data: _data,
      peso: p,
      alturaCm: a,
      notas: _notas.text.trim(),
    );
    await ref.read(repoProvider).guardarConsultaObesidade(c);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imc = _imc;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existente == null ? 'Nova consulta' : 'Editar consulta',
                textAlign: TextAlign.center,
                style: fonteTitulo.copyWith(fontSize: 24)),
            const SizedBox(height: 16),
            InkWell(
              onTap: _escolherData,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da consulta',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_data)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _peso,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _altura,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Altura',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AuraCard(
              color: AuraCores.fundoFim,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: AuraCores.rosa),
                    const SizedBox(width: 12),
                    Expanded(
                      child: imc == null
                          ? const Text('IMC: indica o peso e a altura')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('IMC ${fmtNum(imc)} kg/m²',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                Text(classificarImc(imc)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notas,
              minLines: 5,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notas da consulta',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AuraCores.rosa,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: (_pesoKg != null && _alturaCm != null) ? _guardar : null,
              child: const Text('Guardar consulta'),
            ),
          ],
        ),
      ),
    );
  }
}
