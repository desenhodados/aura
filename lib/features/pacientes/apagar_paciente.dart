import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/models.dart';

/// Pede confirmação e apaga o paciente com todos os seus dados.
/// Devolve true se foi apagado.
Future<bool> apagarPacienteComConfirmacao(
  BuildContext context,
  WidgetRef ref,
  Paciente p,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Apagar ${p.nome}?'),
      content: const Text(
          'Isto apaga a ficha, o consentimento, a assinatura e todas as fotografias deste paciente. Não pode ser desfeito.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Apagar'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(repoProvider).apagarPaciente(p.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${p.nome} foi apagado')));
  }
  return true;
}
