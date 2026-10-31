import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';

class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  // ---- Helpers de UI ----

  Widget _seccao(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
        child: Text(
          t.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: AuraCores.textoSuave,
          ),
        ),
      );

  Widget _item({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icone, color: AuraCores.rosa),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );

  Widget _itemModelos(BuildContext context) => _item(
        icone: Icons.description_outlined,
        titulo: 'Modelos de documentos',
        subtitulo:
            'Consentimentos informados e recomendações pós-tratamento',
        onTap: () => context.push('/modelos'),
      );

  Widget _itemAssinatura(BuildContext context) => _item(
        icone: Icons.draw_outlined,
        titulo: 'Assinatura da médica',
        subtitulo: 'Guardada uma vez e usada nos consentimentos',
        onTap: () => context.push('/assinatura-medica'),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(temaModoProvider);
    final ultima = ref.watch(ultimaCopiaProvider).valueOrNull;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações', style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: ListView(
        children: [
          // ---------- Aparência ----------
          _seccao('Aparência'),
          SwitchListTile(
            secondary: Icon(
              modo == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AuraCores.rosa,
            ),
            title: const Text('Modo escuro'),
            subtitle: Text(
              modo == ThemeMode.dark
                  ? 'Ativo: fundo escuro'
                  : 'Desligado: fundo claro',
            ),
            value: modo == ThemeMode.dark,
            onChanged: (v) {
              final novo = v ? ThemeMode.dark : ThemeMode.light;
              ref.read(temaModoProvider.notifier).state = novo;
              ref.read(repoProvider).guardarTema(v ? 'escuro' : 'claro');
            },
          ),

          // ---------- Documentos (APENAS UMA VEZ) ----------
          _seccao('Documentos'),
          _itemModelos(context),
          _itemAssinatura(context),

          // ---------- Dados ----------
          _seccao('Dados'),
          _item(
            icone: Icons.backup_outlined,
            titulo: 'Backup',
            subtitulo: ultima == null
                ? 'Guardar uma cópia numa pasta à tua escolha'
                : 'Última cópia: ${fmt.format(ultima)}',
            onTap: () => context.push('/copia/backup'),
          ),
          _item(
            icone: Icons.settings_backup_restore_outlined,
            titulo: 'Restore',
            subtitulo: 'Repor os dados a partir de uma cópia guardada',
            onTap: () => context.push('/copia/restore'),
          ),
        ],
      ),
    );
  }
}
