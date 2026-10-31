import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/imagem_blob.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import 'fotos_page.dart';

/// Duas fotografias lado a lado (por defeito: uma "antes" e uma "depois").
class ComparadorPage extends ConsumerStatefulWidget {
  const ComparadorPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ComparadorPage> createState() => _ComparadorPageState();
}

class _ComparadorPageState extends ConsumerState<ComparadorPage> {
  String? _a;
  String? _b;

  @override
  Widget build(BuildContext context) {
    final fotos = ref.watch(fotosProvider(widget.id)).valueOrNull ?? [];

    Foto escolher(String? id, String momento, Foto alternativa) {
      for (final f in fotos) {
        if (f.id == id) return f;
      }
      for (final f in fotos) {
        if (f.momento == momento) return f;
      }
      return alternativa;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Comparar', style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: fotos.length < 2
          ? const Center(child: Text('São precisas pelo menos 2 fotografias.'))
          : Builder(builder: (_) {
              final fa = escolher(_a, 'antes', fotos.first);
              final fb = escolher(_b, 'depois', fotos.last);
              return Row(
                children: [
                  Expanded(
                    child: _Painel(
                        fotos: fotos,
                        atual: fa,
                        aoMudar: (v) => setState(() => _a = v)),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _Painel(
                        fotos: fotos,
                        atual: fb,
                        aoMudar: (v) => setState(() => _b = v)),
                  ),
                ],
              );
            }),
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.fotos, required this.atual, required this.aoMudar});
  final List<Foto> fotos;
  final Foto atual;
  final ValueChanged<String> aoMudar;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String>(
              isExpanded: true,
              value: atual.id,
              items: [
                for (final f in fotos)
                  DropdownMenuItem(
                    value: f.id,
                    child: Text(legendaFoto(f), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) {
                if (v != null) aoMudar(v);
              },
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              maxScale: 5,
              child: ImagemBlob(atual.caminho, fit: BoxFit.contain),
            ),
          ),
        ],
      );
}
