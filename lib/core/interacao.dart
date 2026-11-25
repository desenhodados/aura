import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tema.dart';

// ---------------------------------------------------------------------------
// 1. Toque duplo, ação dupla
// ---------------------------------------------------------------------------

final Set<Object> _emCurso = {};

/// Corre [acao] só se não estiver já a correr outra com a mesma [chave].
/// Um segundo toque enquanto a primeira ainda decorre é ignorado, para não
/// guardar, enviar ou abrir a mesma coisa duas vezes.
Future<void> umaVez(Object chave, Future<void> Function() acao) async {
  if (!_emCurso.add(chave)) return;
  try {
    await acao();
  } finally {
    _emCurso.remove(chave);
  }
}

DateTime _ultimaNavegacao = DateTime.fromMillisecondsSinceEpoch(0);

extension NavegacaoSegura on BuildContext {
  /// Igual a `context.push`, mas ignora um segundo toque logo a seguir
  /// (assim a mesma página não abre duas vezes).
  Future<T?> abrir<T extends Object?>(String rota, {Object? extra}) {
    final agora = DateTime.now();
    if (agora.difference(_ultimaNavegacao) <
        const Duration(milliseconds: 600)) {
      return Future<T?>.value();
    }
    _ultimaNavegacao = agora;
    return push<T>(rota, extra: extra);
  }
}

// ---------------------------------------------------------------------------
// 2. Erros crus no ecrã
// ---------------------------------------------------------------------------

/// Mostra uma mensagem simples em vez do erro técnico.
/// O erro técnico fica só no registo da app (para quem a desenvolve).
Future<void> avisarErro(BuildContext context, String mensagem, Object erro,
    [StackTrace? pilha]) async {
  debugPrint('Aura: $mensagem\n$erro${pilha == null ? '' : '\n$pilha'}');
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Algo correu mal'),
      content: Text(mensagem),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// 3. Voltar apaga o formulário
// ---------------------------------------------------------------------------

/// Pergunta se quer mesmo sair e perder o que escreveu.
Future<bool> confirmarSairSemGuardar(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair sem guardar?'),
        content: const Text(
            'Há alterações que ainda não foram guardadas. Se saíres agora, perdem-se.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair sem guardar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AuraCores.rosa),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar a editar'),
          ),
        ],
      ),
    ) ??
    false;

/// Enquanto [alterado] for verdadeiro, o botão/gesto "voltar", tocar fora de
/// uma folha ou o ✕ perguntam antes de fechar, em vez de apagar o que foi
/// escrito.
class ProtegerSaida extends StatelessWidget {
  const ProtegerSaida({super.key, required this.alterado, required this.child});
  final bool alterado;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
        canPop: !alterado,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final sair = await confirmarSairSemGuardar(context);
          if (sair && context.mounted) Navigator.of(context).pop();
        },
        child: child,
      );
}

/// Abre uma folha (bottom sheet) com formulário.
/// Não fecha ao arrastar para baixo: esse gesto fechava sem perguntar e
/// perdia-se o que estava escrito. Fecha-se no ✕ do [TituloFolha], ao tocar
/// fora ou com "voltar" (que perguntam se houver alterações).
Future<T?> abrirFolhaFormulario<T>(
        BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      showDragHandle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: builder,
    );

/// Título de uma folha de formulário, com botão ✕ para fechar.
class TituloFolha extends StatelessWidget {
  const TituloFolha(this.texto, {super.key, this.subtitulo});
  final String texto;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                children: [
                  Text(texto,
                      textAlign: TextAlign.center,
                      style: fonteTitulo.copyWith(fontSize: 24)),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitulo!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AuraCores.textoSuave)),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Fechar',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.maybePop(context),
            ),
          ],
        ),
      );
}
