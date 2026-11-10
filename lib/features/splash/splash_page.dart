import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/aura_simbolo.dart';
import '../../core/tema.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final Animation<double> _simboloFade = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _simboloEscala = Tween(begin: 0.85, end: 1.0)
      .animate(CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
  ));
  late final Animation<double> _nomeFade = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
  );
  late final Animation<double> _legendaFade = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _entrada.dispose();
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final tamanho = math.min(largura * 0.62, 320.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.escuro
                ? const [AuraCores.fundoEscuro, AuraCores.fundoEscuroFim]
                : const [AuraCores.fundo, AuraCores.fundoFim],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: tamanho * 1.5,
                height: tamanho * 1.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ondas suaves a expandir (a "aura")
                    AnimatedBuilder(
                      animation: _pulso,
                      builder: (_, __) => CustomPaint(
                        size: Size.square(tamanho * 1.5),
                        painter: _OndasPainter(_pulso.value),
                      ),
                    ),
                    FadeTransition(
                      opacity: _simboloFade,
                      child: ScaleTransition(
                        scale: _simboloEscala,
                        child: AuraSimbolo(tamanho: tamanho),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _nomeFade,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.15), end: Offset.zero)
                      .animate(_nomeFade),
                  child: Text(
                    'AURA',
                    style: fonteTitulo.copyWith(
                      fontSize: 44,
                      letterSpacing: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _legendaFade,
                child: Column(
                  children: [
                    Container(width: 56, height: 1.5, color: AuraCores.rosaDourado),
                    const SizedBox(height: 14),
                    Text(
                      'medicina estética',
                      style: fonteTitulo.copyWith(
                        fontSize: 16,
                        letterSpacing: 2.5,
                        fontStyle: FontStyle.italic,
                        color: AuraCores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OndasPainter extends CustomPainter {
  _OndasPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final maximo = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final fase = (t + i / 3) % 1.0;
      final raio = maximo * (0.45 + 0.55 * fase);
      final opacidade = (1 - fase) * 0.35;
      canvas.drawCircle(
        centro,
        raio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AuraCores.rosaDourado.withOpacity(opacidade),
      );
    }
  }

  @override
  bool shouldRepaint(_OndasPainter old) => old.t != t;
}
