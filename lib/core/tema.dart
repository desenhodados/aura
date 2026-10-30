import 'package:flutter/material.dart';

class AuraCores {
  static const fundo = Color(0xFFFFF8F1);
  static const fundoFim = Color(0xFFFBE6DA);
  static const rosaDourado = Color(0xFFE9B08F);
  static const rosa = Color(0xFFC9788A);
  static const texto = Color(0xFFB46A5C);
  static const textoSuave = Color(0xFFC9988A);
}

ThemeData temaAura() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AuraCores.rosa,
        surface: AuraCores.fundo,
      ),
      scaffoldBackgroundColor: AuraCores.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AuraCores.fundo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );

const fonteTitulo = TextStyle(
  fontFamilyFallback: ['Georgia', 'serif'],
  color: AuraCores.texto,
);

/// Cartão com o estilo da Aura (não depende da API de temas do Flutter).
class AuraCard extends StatelessWidget {
  const AuraCard({super.key, this.color, this.margin, this.child});
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Card(
        color: color ?? Colors.white,
        elevation: 0,
        margin: margin,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF3DACB)),
        ),
        child: child,
      );
}
