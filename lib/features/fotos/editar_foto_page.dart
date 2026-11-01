import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

enum _Ferramenta { caneta, marcador, linha }

/// Um traço desenhado. Os pontos são relativos (0 a 1) à imagem, para
/// ficarem no sítio certo em qualquer tamanho.
class _Traco {
  _Traco(this.ferramenta, this.cor, this.largura, this.pontos);
  final _Ferramenta ferramenta;
  final Color cor;
  final double largura; // fração da largura da imagem
  final List<Offset> pontos;
}

class _Anotacoes extends CustomPainter {
  _Anotacoes(this.tracos, {this.imagem});
  final List<_Traco> tracos;
  final ui.Image? imagem; // só usada ao exportar

  @override
  void paint(Canvas canvas, Size size) {
    final img = imagem;
    if (img != null) {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.high,
      );
    }
    for (final t in tracos) {
      _desenhar(canvas, size, t);
    }
  }

  void _desenhar(Canvas c, Size s, _Traco t) {
    if (t.pontos.isEmpty) return;
    Offset o(Offset p) => Offset(p.dx * s.width, p.dy * s.height);
    final marcador = t.ferramenta == _Ferramenta.marcador;
    final largura = t.largura * s.width * (marcador ? 4 : 1);
    final cor = marcador ? t.cor.withOpacity(0.38) : t.cor;

    if (t.pontos.length == 1) {
      c.drawCircle(o(t.pontos.first), largura / 2, Paint()..color = cor);
      return;
    }
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeCap = marcador ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = largura;

    if (t.ferramenta == _Ferramenta.linha) {
      c.drawLine(o(t.pontos.first), o(t.pontos.last), paint);
      return;
    }
    final path = Path()..moveTo(o(t.pontos.first).dx, o(t.pontos.first).dy);
    for (final p in t.pontos.skip(1)) {
      path.lineTo(o(p).dx, o(p).dy);
    }
    c.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_Anotacoes antigo) => true;
}

/// Editor de fotografias: caneta, marcador e linha reta (para sublinhar).
class EditarFotoPage extends ConsumerStatefulWidget {
  const EditarFotoPage({super.key, required this.foto});
  final Foto foto;
  @override
  ConsumerState<EditarFotoPage> createState() => _EditarFotoPageState();
}

class _EditarFotoPageState extends ConsumerState<EditarFotoPage> {
  static const _cores = [
    Color(0xFFE53935), // vermelho
    Color(0xFFFFD600), // amarelo
    Color(0xFF43A047), // verde
    Color(0xFF1E88E5), // azul
    Colors.white,
    Colors.black,
  ];

  Uint8List? _bytes;
  ui.Image? _img;
  final List<_Traco> _tracos = [];
  _Traco? _atual;
  _Ferramenta _ferramenta = _Ferramenta.caneta;
  Color _cor = _cores.first;
  double _largura = 0.006;
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final b = await ref.read(repoProvider).lerBlob(widget.foto.caminho);
    if (b == null) {
      if (mounted) Navigator.pop(context, false);
      return;
    }
    final img = await ui.decodeImageFromList(b);
    if (mounted) {
      setState(() {
        _bytes = b;
        _img = img;
      });
    }
  }

  Offset _rel(Offset local, Size s) => Offset(
        (local.dx / s.width).clamp(0.0, 1.0),
        (local.dy / s.height).clamp(0.0, 1.0),
      );

  void _inicio(Offset local, Size s) {
    final t = _Traco(_ferramenta, _cor, _largura, [_rel(local, s)]);
    setState(() {
      _atual = t;
      _tracos.add(t);
    });
  }

  void _mover(Offset local, Size s) {
    final t = _atual;
    if (t == null) return;
    setState(() => t.pontos.add(_rel(local, s)));
  }

  void _aviso(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<Uint8List> _exportar() async {
    final img = _img!;
    final w0 = img.width.toDouble();
    final h0 = img.height.toDouble();
    final escala = math.min(1.0, 1600 / math.max(w0, h0));
    final w = (w0 * escala).round();
    final h = (h0 * escala).round();
    final gravador = ui.PictureRecorder();
    final canvas = Canvas(gravador);
    _Anotacoes(_tracos, imagem: img)
        .paint(canvas, Size(w.toDouble(), h.toDouble()));
    final final_ = await gravador.endRecording().toImage(w, h);
    final dados = await final_.toByteData(format: ui.ImageByteFormat.png);
    return dados!.buffer.asUint8List();
  }

  Future<void> _guardar() async {
    if (_tracos.isEmpty) {
      _aviso('Ainda não fizeste nenhuma marca.');
      return;
    }
    final modo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar fotografia editada'),
        content: const Text(
            'Podes guardar como uma nova foto (a original fica como estava) ou substituir a original.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'substituir'),
              child: const Text('Substituir original')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, 'nova'),
              child: const Text('Nova foto')),
        ],
      ),
    );
    if (modo == null || !mounted) return;

    setState(() => _aGuardar = true);
    try {
      final bytes = await _exportar();
      final repo = ref.read(repoProvider);
      final f = widget.foto;
      final chave = 'foto_${const Uuid().v4()}';
      await repo.guardarBlob(chave, bytes);
      if (modo == 'nova') {
        await repo.guardarFoto(Foto(
          id: const Uuid().v4(),
          pacienteId: f.pacienteId,
          consultaId: f.consultaId,
          caminho: chave,
          angulo: '${f.angulo ?? 'Foto'} (anotada)',
          momento: f.momento,
          tiradaEm: f.tiradaEm,
        ));
      } else {
        await repo.guardarFoto(Foto(
          id: f.id,
          pacienteId: f.pacienteId,
          consultaId: f.consultaId,
          caminho: chave,
          angulo: f.angulo,
          momento: f.momento,
          tiradaEm: f.tiradaEm,
        ));
        await repo.apagarBlob(f.caminho);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _aviso('Não foi possível guardar a fotografia: $e');
      if (mounted) setState(() => _aGuardar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = _img;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar foto', style: fonteTitulo.copyWith(fontSize: 20)),
        actions: [
          IconButton(
            tooltip: 'Anular último traço',
            icon: const Icon(Icons.undo),
            onPressed: _tracos.isEmpty
                ? null
                : () => setState(() => _tracos.removeLast()),
          ),
          IconButton(
            tooltip: 'Limpar tudo',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _tracos.isEmpty ? null : () => setState(_tracos.clear),
          ),
          IconButton(
            tooltip: 'Guardar',
            icon: const Icon(Icons.check),
            onPressed: _aGuardar ? null : _guardar,
          ),
        ],
      ),
      body: img == null || _bytes == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: img.width / img.height,
                      child: LayoutBuilder(
                        builder: (_, caixa) {
                          final tamanho = Size(caixa.maxWidth, caixa.maxHeight);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (d) => _inicio(d.localPosition, tamanho),
                            onPanUpdate: (d) => _mover(d.localPosition, tamanho),
                            onPanEnd: (_) => _atual = null,
                            onTapDown: (d) {
                              _inicio(d.localPosition, tamanho);
                              _atual = null;
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(_bytes!, fit: BoxFit.fill),
                                CustomPaint(painter: _Anotacoes(_tracos)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SegmentedButton<_Ferramenta>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                                value: _Ferramenta.caneta,
                                icon: Icon(Icons.edit_outlined),
                                label: Text('Riscar')),
                            ButtonSegment(
                                value: _Ferramenta.marcador,
                                icon: Icon(Icons.highlight_outlined),
                                label: Text('Marcador')),
                            ButtonSegment(
                                value: _Ferramenta.linha,
                                icon: Icon(Icons.horizontal_rule),
                                label: Text('Sublinhar')),
                          ],
                          selected: {_ferramenta},
                          onSelectionChanged: (s) =>
                              setState(() => _ferramenta = s.first),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final c in _cores)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () => setState(() => _cor = c),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cor == c
                                            ? AuraCores.rosa
                                            : Colors.grey,
                                        width: _cor == c ? 3.5 : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Slider(
                                min: 0.003,
                                max: 0.02,
                                value: _largura,
                                activeColor: AuraCores.rosa,
                                onChanged: (v) => setState(() => _largura = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
