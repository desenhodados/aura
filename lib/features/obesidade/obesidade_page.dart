import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/formatos.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import 'consulta_ob_sheet.dart';
import 'dart:ui' show TextDirection;

class ObesidadePage extends ConsumerWidget {
  const ObesidadePage({super.key, required this.id});
  final String id;

  Future<void> _abrir(BuildContext context, {ConsultaObesidade? c, double? altura}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: AuraCores.fundo,
        builder: (_) => ConsultaObSheet(
            pacienteId: id, existente: c, alturaAnterior: altura),
      );

  Future<void> _apagar(BuildContext context, WidgetRef ref, ConsultaObesidade c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar consulta?'),
        content: Text(
            'Consulta de ${DateFormat('dd/MM/yyyy').format(c.data)}. Não pode ser desfeito.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(repoProvider).apagarConsultaObesidade(c.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(consultasObesidadeProvider(id)).valueOrNull ?? [];
    final ultima = lista.isEmpty ? null : lista.last;
    final primeira = lista.isEmpty ? null : lista.first;
    final fmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Consultas de obesidade',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: lista.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Ainda sem consultas.\nToca em "Nova consulta" para registar peso, altura e notas.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                AuraCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Última consulta · ${fmt.format(ultima!.data)}',
                            style: const TextStyle(color: AuraCores.textoSuave)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 20,
                          runSpacing: 6,
                          children: [
                            _Dado('Peso', '${fmtNum(ultima.peso)} kg'),
                            _Dado('Altura', '${fmtNum(ultima.alturaCm, casas: 0)} cm'),
                            _Dado('IMC', fmtNum(ultima.imc)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(classificarImc(ultima.imc)),
                        if (lista.length > 1) ...[
                          const Divider(height: 24),
                          Text(
                            'Desde ${fmt.format(primeira!.data)}: '
                            '${_sinal(ultima.peso - primeira.peso)} kg · '
                            'IMC ${_sinal(ultima.imc - primeira.imc)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: CustomPaint(painter: _GraficoPeso(lista)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = lista.length - 1; i >= 0; i--)
                  _CartaoConsulta(
                    c: lista[i],
                    anterior: i > 0 ? lista[i - 1] : null,
                    aoTocar: () =>
                        _abrir(context, c: lista[i], altura: lista[i].alturaCm),
                    aoApagar: () => _apagar(context, ref, lista[i]),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AuraCores.rosa,
        foregroundColor: Colors.white,
        onPressed: () => _abrir(context, altura: ultima?.alturaCm),
        icon: const Icon(Icons.add),
        label: const Text('Nova consulta'),
      ),
    );
  }
}

String _sinal(double v) {
  final s = fmtNum(v.abs());
  if (v.abs() < 0.05) return '0,0';
  return v > 0 ? '+$s' : '-$s';
}

class _Dado extends StatelessWidget {
  const _Dado(this.rotulo, this.valor);
  final String rotulo;
  final String valor;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(fontSize: 12, color: AuraCores.textoSuave)),
          Text(valor,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      );
}

class _CartaoConsulta extends StatelessWidget {
  const _CartaoConsulta({
    required this.c,
    required this.anterior,
    required this.aoTocar,
    required this.aoApagar,
  });
  final ConsultaObesidade c;
  final ConsultaObesidade? anterior;
  final VoidCallback aoTocar;
  final VoidCallback aoApagar;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final dif = anterior == null ? null : c.peso - anterior!.peso;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AuraCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(fmt.format(c.data),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'apagar') aoApagar();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'apagar',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                                Icon(Icons.delete_outline, color: Colors.red),
                            title: Text('Apagar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '${fmtNum(c.peso)} kg · ${fmtNum(c.alturaCm, casas: 0)} cm · '
                    'IMC ${fmtNum(c.imc)} (${classificarImc(c.imc)})'
                    '${dif == null ? '' : '\nVariação: ${_sinal(dif)} kg'}',
                  ),
                ),
                if (c.notas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Text(c.notas,
                        style: const TextStyle(color: Colors.black54)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Evolução do peso ao longo das consultas.
class _GraficoPeso extends CustomPainter {
  _GraficoPeso(this.lista);
  final List<ConsultaObesidade> lista;

  @override
  void paint(Canvas canvas, Size size) {
    if (lista.length < 2) return;
    final pesos = lista.map((c) => c.peso).toList();
    var minV = pesos.reduce((a, b) => a < b ? a : b);
    var maxV = pesos.reduce((a, b) => a > b ? a : b);
    if (maxV - minV < 1) {
      maxV += 0.5;
      minV -= 0.5;
    }
    const mx = 34.0, my = 16.0;
    final w = size.width - 2 * mx, h = size.height - 2 * my;
    Offset ponto(int i) => Offset(
          mx + w * i / (lista.length - 1),
          my + h * (1 - (pesos[i] - minV) / (maxV - minV)),
        );

    final linha = Paint()
      ..color = AuraCores.rosa
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final caminho = Path()..moveTo(ponto(0).dx, ponto(0).dy);
    for (var i = 1; i < lista.length; i++) {
      caminho.lineTo(ponto(i).dx, ponto(i).dy);
    }
    canvas.drawPath(caminho, linha);

    final bola = Paint()..color = AuraCores.rosa;
    for (var i = 0; i < lista.length; i++) {
      canvas.drawCircle(ponto(i), 4, bola);
    }

    void texto(String t, Offset o) {
      final tp = TextPainter(
        text: TextSpan(
            text: t,
            style: const TextStyle(fontSize: 11, color: AuraCores.texto)),
       textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy));
    }

    texto(fmtNum(pesos.first), ponto(0).translate(0, -16));
    texto(fmtNum(pesos.last), ponto(lista.length - 1).translate(0, -16));
  }

  @override
  bool shouldRepaint(_GraficoPeso old) => old.lista != lista;
}
