import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/aura_simbolo.dart';
import '../../core/aura_drawer.dart';
import '../../core/avatar_paciente.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/models.dart';
import '../pacientes/apagar_paciente.dart';
import 'nova_ficha_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);
    final preenchidas =
        ref.watch(fichasPreenchidasProvider).valueOrNull ?? <String>{};

    return Scaffold(
      drawer: const AuraDrawer(),
      appBar: AppBar(
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min, // importante!
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const AuraSimbolo(tamanho: 38),
      const SizedBox(width: 8),
      Text('Aura',
          style: fonteTitulo.copyWith(fontSize: 26, letterSpacing: 4)),
    ],
  ),
),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => ref.read(pesquisaProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, telemóvel ou nº de utente',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.superficie,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: context.borda),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: context.borda),
                ),
              ),
            ),
          ),
          const _AvisoCopia(),
          Expanded(
            child: pacientes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (lista) => lista.isEmpty
                  ? const _EstadoVazio()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _CartaoPaciente(lista[i],
                          preenchida: preenchidas.contains(lista[i].id)),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AuraCores.rosa,
        foregroundColor: Colors.white,
        onPressed: () async {
          final id = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            builder: (_) => const NovaFichaSheet(),
          );
          if (id != null && context.mounted) context.push('/paciente/$id/ficha?novo=1');
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nova ficha'),
      ),
    );
  }
}

class _CartaoPaciente extends ConsumerWidget {
  const _CartaoPaciente(this.p, {required this.preenchida});
  final Paciente p;
  final bool preenchida;

  int? get _idade {
    final n = p.dataNascimento;
    if (n == null) return null;
    final hoje = DateTime.now();
    var idade = hoje.year - n.year;
    if (hoje.month < n.month || (hoje.month == n.month && hoje.day < n.day)) {
      idade--;
    }
    return idade;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalhes = [
      if (_idade != null) '$_idade anos',
      if (p.telemovel != null && p.telemovel!.isNotEmpty) p.telemovel!,
    ].join(' · ');

    return AuraCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: AvatarPaciente(p, raio: 24),
        title: Text(p.nome,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          detalhes.isEmpty
              ? 'Criada a ${DateFormat('dd/MM/yyyy').format(p.criadoEm)}'
              : detalhes,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              preenchida ? Icons.check_circle : Icons.edit_note,
              color: preenchida
                  ? const Color(0xFF7BA37B)
                  : AuraCores.textoSuave,
            ),
            PopupMenuButton<String>(
              tooltip: 'Opções',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'editar') context.push('/paciente/${p.id}/ficha');
                if (v == 'identificacao') abrirIdentificacao(context, paciente: p);
                if (v == 'apagar') apagarPacienteComConfirmacao(context, ref, p);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar ficha'),
                  ),
                ),
                PopupMenuItem(
                  value: 'identificacao',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.badge_outlined),
                    title: Text('Editar identificação'),
                  ),
                ),
                PopupMenuItem(
                  value: 'apagar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Apagar', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => context.push('/paciente/${p.id}'),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 0.8,
                child: const AuraSimbolo(tamanho: 150),
              ),
              const SizedBox(height: 12),
              Text('Ainda sem pacientes',
                  style: fonteTitulo.copyWith(fontSize: 22)),
              const SizedBox(height: 6),
              const Text(
                'Toca em "Nova ficha" para registar a primeira avaliação.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}


/// Lembrete quando há dados e a última cópia tem mais de 7 dias (ou não existe).
class _AvisoCopia extends ConsumerWidget {
  const _AvisoCopia();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ultima = ref.watch(ultimaCopiaProvider).valueOrNull;
    final temDados =
        (ref.watch(pacientesProvider).valueOrNull ?? const []).isNotEmpty;
    final dias = ultima == null ? null : DateTime.now().difference(ultima).inDays;
    if (!temDados || (dias != null && dias < 7)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AuraCard(
        color: context.destaque,
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.backup_outlined, color: AuraCores.rosa),
          title: Text(dias == null
              ? 'Ainda não fizeste cópia de segurança'
              : 'Última cópia há $dias dias'),
          trailing: TextButton(
            onPressed: () => context.push('/copia'),
            child: const Text('Fazer agora'),
          ),
        ),
      ),
    );
  }
}
