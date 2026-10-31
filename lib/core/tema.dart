import 'package:flutter/material.dart';

class AuraCores {
  // modo claro
  static const fundo = Color(0xFFFFF8F1);
  static const fundoFim = Color(0xFFFBE6DA);
  // modo escuro
  static const fundoEscuro = Color(0xFF1B1517);
  static const fundoEscuroFim = Color(0xFF2A1F23);
  // comuns aos dois modos
  static const rosaDourado = Color(0xFFE9B08F);
  static const rosa = Color(0xFFC9788A);
  static const texto = Color(0xFFB46A5C);
  static const textoSuave = Color(0xFFC9988A);
}

/// Cores que se adaptam ao modo claro/escuro.
extension AuraContexto on BuildContext {
  bool get escuro => Theme.of(this).brightness == Brightness.dark;
  Color get superficie => escuro ? const Color(0xFF2A2023) : Colors.white;
  Color get destaque => escuro ? const Color(0xFF3B2C31) : AuraCores.fundoFim;
  Color get borda => escuro ? const Color(0xFF4E3C42) : const Color(0xFFF3DACB);
  Color get fundoPagina => Theme.of(this).scaffoldBackgroundColor;
}

ThemeData temaAura() => _tema(Brightness.light);
ThemeData temaAuraEscuro() => _tema(Brightness.dark);

ThemeData _tema(Brightness brilho) {
  final escuro = brilho == Brightness.dark;
  final fundo = escuro ? AuraCores.fundoEscuro : AuraCores.fundo;
  return ThemeData(
    useMaterial3: true,
    brightness: brilho,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AuraCores.rosa,
      brightness: brilho,
      surface: fundo,
    ),
    scaffoldBackgroundColor: fundo,
    appBarTheme: AppBarTheme(
      backgroundColor: fundo,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: fundo,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

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
        color: color ?? context.superficie,
        elevation: 0,
        margin: margin,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.borda),
        ),
        child: child,
      );
}
