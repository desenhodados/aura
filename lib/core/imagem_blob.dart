import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

/// Mostra uma imagem guardada (foto ou assinatura) a partir da sua chave.
class ImagemBlob extends ConsumerStatefulWidget {
  const ImagemBlob(
    this.chave, {
    super.key,
    this.fit = BoxFit.cover,
    this.largura,
    this.altura,
    this.cacheWidth,
  });
  final String chave;
  final BoxFit fit;
  final double? largura;
  final double? altura;
  final int? cacheWidth;

  @override
  ConsumerState<ImagemBlob> createState() => _ImagemBlobState();
}

class _ImagemBlobState extends ConsumerState<ImagemBlob> {
  late Future<Uint8List?> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ref.read(repoProvider).lerBlob(widget.chave);
  }

  @override
  void didUpdateWidget(ImagemBlob old) {
    super.didUpdateWidget(old);
    if (old.chave != widget.chave) {
      _futuro = ref.read(repoProvider).lerBlob(widget.chave);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
        future: _futuro,
        builder: (_, s) {
          final b = s.data;
          if (b == null) {
            return SizedBox(
              width: widget.largura,
              height: widget.altura,
              child: s.connectionState == ConnectionState.done
                  ? const Icon(Icons.broken_image_outlined)
                  : const ColoredBox(color: Color(0x11000000)),
            );
          }
          return Image.memory(
            b,
            fit: widget.fit,
            width: widget.largura,
            height: widget.altura,
            cacheWidth: widget.cacheWidth,
            gaplessPlayback: true,
          );
        },
      );
}
