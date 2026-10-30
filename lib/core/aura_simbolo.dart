import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Símbolo da Aura desenhado em código (não precisa de ficheiros de imagem).
class AuraSimbolo extends StatelessWidget {
  const AuraSimbolo({super.key, this.tamanho = 200});
  final double tamanho;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: tamanho,
        height: tamanho,
        child: CustomPaint(painter: _SimboloPainter()),
      );
}

class _SimboloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 1024;
    final c = Offset(512 * s, 512 * s);
    Offset o(double x, double y) => Offset(x * s, y * s);

    // halo difuso
    final haloRect = Rect.fromCircle(center: c, radius: 470 * s);
    canvas.drawCircle(
      c,
      470 * s,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x8CF6C9A8), Color(0x2EF6C9A8), Color(0x00F6C9A8)],
          stops: [0, 0.6, 1],
        ).createShader(haloRect),
    );

    // anéis da aura
    final aneis = [(400.0, 3.0, 0.30), (335.0, 4.0, 0.50), (270.0, 5.0, 0.75)];
    for (final (r, w, op) in aneis) {
      final rect = Rect.fromCircle(center: c, radius: r * s);
      canvas.drawCircle(
        c,
        r * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * s
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE9B08F).withOpacity(op),
              const Color(0xFFC9788A).withOpacity(op),
            ],
          ).createShader(rect),
      );
    }

    // orbe central
    final orbRect = Rect.fromCircle(center: c, radius: 205 * s);
    canvas.drawCircle(
      c,
      205 * s,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.16, -0.24),
          radius: 0.9,
          colors: [Color(0xFFFFF3E4), Color(0xFFF6C9A8), Color(0xFFD98F7A)],
          stops: [0, 0.45, 1],
        ).createShader(orbRect),
    );

    // brilho
    canvas.save();
    canvas.translate(450 * s, 440 * s);
    canvas.rotate(-math.pi / 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 170 * s, height: 110 * s),
      Paint()..color = Colors.white.withOpacity(0.35),
    );
    canvas.restore();

    // estrela de 4 pontas
    final estrela = Path()
      ..moveTo(512 * s, 400 * s)
      ..cubicTo(520 * s, 480 * s, 544 * s, 504 * s, 624 * s, 512 * s)
      ..cubicTo(544 * s, 520 * s, 520 * s, 544 * s, 512 * s, 624 * s)
      ..cubicTo(504 * s, 544 * s, 480 * s, 520 * s, 400 * s, 512 * s)
      ..cubicTo(480 * s, 504 * s, 504 * s, 480 * s, 512 * s, 400 * s)
      ..close();
    canvas.drawPath(
        estrela, Paint()..color = Colors.white.withOpacity(0.95));

    // faíscas
    canvas.drawCircle(o(770, 270), 9 * s, Paint()..color = const Color(0xFFE9B08F));
    canvas.drawCircle(o(265, 745), 7 * s,
        Paint()..color = const Color(0xFFC9788A).withOpacity(0.8));
    canvas.drawCircle(o(800, 720), 5 * s,
        Paint()..color = const Color(0xFFE9B08F).withOpacity(0.8));
  }

  @override
  bool shouldRepaint(_SimboloPainter old) => false;
}
