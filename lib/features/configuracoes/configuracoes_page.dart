import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';

class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  Widget _seccao(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: AuraCores.textoSuave)),
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
          _seccao('Aparência'),
          SwitchListTile(
            secondary: Icon(
              modo == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AuraCores.rosa,
            ),
            title: const Text('Modo escuro'),
            subtitle: Text(modo == ThemeMode.dark
                ? 'Ativo: fundo escuro'
                : 'Desligado: fundo claro'),
            value: modo == ThemeMode.dark,
            onChanged: (v) {
              final novo = v ? ThemeMode.dark : ThemeMode.light;
              ref.read(temaModoProvider.notifier).state = novo;
              ref.read(repoProvider).guardarTema(v ? 'escuro' : 'claro');
            },
          ),
          _seccao('Documentos'),
          ListTile(
            leading:
                const Icon(Icons.description_outlined, color: AuraCores.rosa),
            title: const Text('Modelos de documentos'),
            subtitle: const Text(
                'Consentimentos informados e recomendações pós-tratamento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/modelos'),
          ),
          ListTile(
            leading: const Icon(Icons.draw_outlined, color: AuraCores.rosa),
            title: const Text('Assinatura da médica'),
            subtitle: const Text('Usada em todos os consentimentos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/assinatura-medica'),
          ),
          _seccao('Documentos'),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AuraCores.rosa),
            title: const Text('Modelos de documentos'),
            subtitle: const Text(
                'Consentimentos informados e recomendações pós-tratamento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/modelos'),
          ),
          ListTile(
            leading: const Icon(Icons.draw_outlined, color: AuraCores.rosa),
            title: const Text('Assinatura da médica'),
            subtitle: const Text('Guardada uma vez e usada nos consentimentos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/assinatura-medica'),
          ),
          _seccao('Dados'),
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: AuraCores.rosa),
            title: const Text('Backup'),
            subtitle: Text(ultima == null
                ? 'Guardar uma cópia numa pasta à tua escolha'
                : 'Última cópia: ${fmt.format(ultima)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/copia/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore_outlined,
                color: AuraCores.rosa),
            title: const Text('Restore'),
            subtitle: const Text('Repor os dados a partir de uma cópia guardada'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/copia/restore'),
          ),
        ],
      ),
    );
  }
}
