import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';

/// Consentimentos informados por tratamento: lista dos assinados + novo.
class ConsentimentosTratPage extends ConsumerWidget {
  const ConsentimentosTratPage({super.key, required this.id});
  final String id;

  Future<void> _novo(BuildContext context) async {
    final modeloId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _EscolherModelo(),
    );
    if (modeloId != null && context.mounted) {
      context.push('/paciente/$id/consentimentos/assinar/$modeloId');
    }
  }

  Future<void> _apagar(BuildContext context, WidgetRef ref, ConsentimentoTratamento c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar consentimento?'),
        content: Text(
            '"${c.titulo}" assinado em ${DateFormat('dd/MM/yyyy').format(c.assinadoEm)}. Isto remove também a assinatura e não pode ser desfeito.'),
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
    if (ok == true) await ref.read(repoProvider).apagarConsentimentoTrat(c);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(consentimentosTratProvider(id)).valueOrNull ?? [];
    final ass = ref.watch(assinaturaMedicaProvider);
    final semAssinaturaMedica = ass.hasValue && ass.value == null;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Consentimentos informados',
            style: fonteTitulo.copyWith(fontSize: 20)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'modelos') context.push('/modelos');
              if (v == 'assinatura') context.push('/assinatura-medica');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'modelos', child: Text('Modelos de documentos')),
              PopupMenuItem(value: 'assinatura', child: Text('Assinatura da médica')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          if (semAssinaturaMedica)
            AuraCard(
              color: context.destaque,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.draw_outlined, color: AuraCores.rosa),
                title: const Text('A assinatura da médica ainda não está guardada'),
                trailing: TextButton(
                  onPressed: () => context.push('/assinatura-medica'),
                  child: const Text('Guardar'),
                ),
              ),
            ),
          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Ainda sem consentimentos.\nToca em "Novo consentimento" para escolher o tratamento e recolher a assinatura.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final c in lista)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AuraCard(
                child: ListTile(
                  leading: const Icon(Icons.verified_outlined,
                      color: Color(0xFF7BA37B)),
                  title: Text(c.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Assinado em ${fmt.format(c.assinadoEm)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'pdf') context.push('/consentimento-trat/${c.id}/pdf');
                      if (v == 'apagar') _apagar(context, ref, c);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'pdf', child: Text('Ver / PDF / Partilhar')),
                      PopupMenuItem(
                        value: 'apagar',
                        child: Text('Apagar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/consentimento-trat/${c.id}/pdf'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AuraCores.rosa,
        foregroundColor: Colors.white,
        onPressed: () => _novo(context),
        icon: const Icon(Icons.edit_document),
        label: const Text('Novo consentimento'),
      ),
    );
  }
}

class _EscolherModelo extends ConsumerWidget {
  const _EscolherModelo();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelos = ref.watch(modelosProvider('consentimento')).valueOrNull ?? [];
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Escolhe o tratamento',
                  style: fonteTitulo.copyWith(fontSize: 22)),
            ),
            if (modelos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sem modelos. Cria um em "Modelos de documentos".'),
              ),
            for (final m in modelos)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(m.titulo),
                onTap: () => Navigator.pop(context, m.id),
              ),
          ],
        ),
      ),
    );
  }
}
