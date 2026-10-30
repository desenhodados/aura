import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../../data/repositorio.dart';
import 'ficha_modelo.dart';

/// Ficha em passos, com gravação automática.
class FichaFormPage extends ConsumerStatefulWidget {
  const FichaFormPage({super.key, required this.pacienteId, this.novo = false});
  final String pacienteId;
  final bool novo;
  @override
  ConsumerState<FichaFormPage> createState() => _FichaFormPageState();
}

class _FichaFormPageState extends ConsumerState<FichaFormPage> {
  late final Repositorio _repo;
  final Map<String, dynamic> _dados = {};
  final List<Map<String, String>> _trat = [];
  int _passo = 0;
  bool _carregado = false;
  bool _alterado = false;
  Timer? _debounce;

  int get _total => secoes.length + 1; // +1 = tratamentos propostos

  @override
  void initState() {
    super.initState();
    _repo = ref.read(repoProvider);
    _carregar();
  }

  Future<void> _carregar() async {
    final f = await _repo.lerFicha(widget.pacienteId);
    _dados.addAll(dadosDe(f));
    _trat.addAll(tratamentosDe(f));
    if (mounted) setState(() => _carregado = true);
  }

  void _alterou() {
    _alterado = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _guardar);
  }

  Future<void> _guardar() async {
    _alterado = false;
    await _repo.guardarFicha(Ficha(
      pacienteId: widget.pacienteId,
      dadosJson: jsonEncode(_dados),
      tratamentosPropostosJson: jsonEncode(_trat),
      atualizadaEm: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_carregado && _alterado) _guardar();
    super.dispose();
  }

  Future<void> _concluir() async {
    _debounce?.cancel();
    await _guardar();
    if (!mounted) return;
    if (widget.novo) {
      context.pushReplacement('/paciente/${widget.pacienteId}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _passo == _total - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Ficha de avaliação',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: !_carregado
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (_passo + 1) / _total,
                  color: AuraCores.rosa,
                  backgroundColor: AuraCores.fundoFim,
                ),
                Expanded(
                  child: ListView(
                    key: ValueKey(_passo),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: _passo < secoes.length
                        ? [
                            Text('Passo ${_passo + 1} de $_total',
                                style: const TextStyle(
                                    color: AuraCores.textoSuave)),
                            const SizedBox(height: 4),
                            Text(secoes[_passo].titulo,
                                style: fonteTitulo.copyWith(fontSize: 24)),
                            const SizedBox(height: 16),
                            ...secoes[_passo].campos.map(_campo),
                          ]
                        : _passoTratamentos(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        if (_passo > 0)
                          OutlinedButton(
                            onPressed: () => setState(() => _passo--),
                            child: const Text('Anterior'),
                          ),
                        const Spacer(),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AuraCores.rosa),
                          onPressed: ultimo
                              ? _concluir
                              : () => setState(() => _passo++),
                          child: Text(ultimo ? 'Concluir' : 'Seguinte'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------- campos ----------

  Widget _campo(Campo c) {
    switch (c.tipo) {
      case TipoCampo.texto:
      case TipoCampo.textoLongo:
      case TipoCampo.numero:
        final longo = c.tipo == TipoCampo.textoLongo;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            key: ValueKey(c.chave),
            initialValue: _dados[c.chave]?.toString() ?? '',
            keyboardType: c.tipo == TipoCampo.numero
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            minLines: longo ? 2 : 1,
            maxLines: longo ? 5 : 1,
            decoration: InputDecoration(
              labelText: c.rotulo,
              suffixText: c.sufixo,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              _dados[c.chave] = v;
              _alterou();
            },
          ),
        );

      case TipoCampo.simNao:
        final atual = _dados[c.chave];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: Text(c.rotulo)),
              SegmentedButton<String>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'Sim', label: Text('Sim')),
                  ButtonSegment(value: 'Não', label: Text('Não')),
                ],
                selected: atual is String ? {atual} : <String>{},
                onSelectionChanged: (s) {
                  setState(() {
                    if (s.isEmpty) {
                      _dados.remove(c.chave);
                    } else {
                      _dados[c.chave] = s.first;
                    }
                  });
                  _alterou();
                },
              ),
            ],
          ),
        );

      case TipoCampo.escolha:
        final longa = c.opcoes.any((o) => o.length > 28);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!longa || c.rotulo != 'Fototipo')
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(c.rotulo,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              if (longa)
                ...c.opcoes.map((o) {
                  final sel = _dados[c.chave] == o;
                  return AuraCard(
                    color: sel ? AuraCores.fundoFim : Colors.white,
                    child: ListTile(
                      dense: true,
                      title: Text(o),
                      trailing: sel
                          ? const Icon(Icons.check_circle,
                              color: AuraCores.rosa)
                          : null,
                      onTap: () {
                        setState(() {
                          if (sel) {
                            _dados.remove(c.chave);
                          } else {
                            _dados[c.chave] = o;
                          }
                        });
                        _alterou();
                      },
                    ),
                  );
                })
              else
                Wrap(
                  spacing: 8,
                  children: c.opcoes
                      .map((o) => ChoiceChip(
                            label: Text(o),
                            selected: _dados[c.chave] == o,
                            onSelected: (on) {
                              setState(() {
                                if (on) {
                                  _dados[c.chave] = o;
                                } else {
                                  _dados.remove(c.chave);
                                }
                              });
                              _alterou();
                            },
                          ))
                      .toList(),
                ),
            ],
          ),
        );

      case TipoCampo.multi:
        final atual = List<String>.from((_dados[c.chave] as List?) ?? const []);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(c.rotulo,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Wrap(
                spacing: 8,
                children: c.opcoes
                    .map((o) => FilterChip(
                          label: Text(o),
                          selected: atual.contains(o),
                          onSelected: (on) {
                            if (on) {
                              atual.add(o);
                            } else {
                              atual.remove(o);
                            }
                            setState(() {
                              if (atual.isEmpty) {
                                _dados.remove(c.chave);
                              } else {
                                _dados[c.chave] = atual;
                              }
                            });
                            _alterou();
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        );
    }
  }

  // ---------- tratamentos propostos ----------

  List<Widget> _passoTratamentos() => [
        Text('Passo $_total de $_total',
            style: const TextStyle(color: AuraCores.textoSuave)),
        const SizedBox(height: 4),
        Text('Tratamentos propostos',
            style: fonteTitulo.copyWith(fontSize: 24)),
        const SizedBox(height: 16),
        ..._trat.asMap().entries.map((e) => AuraCard(
              child: ListTile(
                title: Text(e.value['tratamento'] ?? ''),
                subtitle: Text(e.value['data'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() => _trat.removeAt(e.key));
                    _alterou();
                  },
                ),
              ),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _adicionarTratamento,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar tratamento'),
        ),
      ];

  Future<void> _adicionarTratamento() async {
    final ctrl = TextEditingController();
    var data = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Tratamento proposto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Tratamento'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(DateFormat('dd/MM/yyyy').format(data)),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'PT'),
                  );
                  if (d != null) setD(() => data = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Adicionar')),
          ],
        ),
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      setState(() => _trat.add({
            'data': DateFormat('dd/MM/yyyy').format(data),
            'tratamento': ctrl.text.trim(),
          }));
      _alterou();
    }
  }
}
