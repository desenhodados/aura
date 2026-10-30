import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/avatar_paciente.dart';
import '../../core/formatos.dart';
import '../../core/imagem_blob.dart';
import '../../data/models.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../ficha/ficha_modelo.dart';
import '../home/nova_ficha_sheet.dart';
import 'apagar_paciente.dart';

/// Ficha preenchida (só leitura) + consentimento, fotografias e PDF/impressão.
class PacientePage extends ConsumerWidget {
  const PacientePage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(pacienteProvider(id)).valueOrNull;
    final ficha = ref.watch(fichaProvider(id)).valueOrNull;
    final consent = ref.watch(consentimentoProvider(id)).valueOrNull;
    final fotos = ref.watch(fotosProvider(id)).valueOrNull ?? [];
    final obes = ref.watch(consultasObesidadeProvider(id)).valueOrNull ?? [];
    final consTrat =
        ref.watch(consentimentosTratProvider(id)).valueOrNull ?? [];
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fmt = DateFormat('dd/MM/yyyy');
    final dados = dadosDe(ficha);
    final trat = tratamentosDe(ficha);
    final idade = idadeDe(p.dataNascimento);

    final ident = <Linha>[
      if (p.dataNascimento != null)
        (
          rotulo: 'Data de nascimento',
          valor: '${fmt.format(p.dataNascimento!)}'
              '${idade != null ? ' · $idade anos' : ''}'
        ),
      if ((p.profissao ?? '').isNotEmpty)
        (rotulo: 'Profissão', valor: p.profissao!),
      if ((p.telemovel ?? '').isNotEmpty)
        (rotulo: 'Telemóvel', valor: p.telemovel!),
      if ((p.email ?? '').isNotEmpty) (rotulo: 'E-mail', valor: p.email!),
      if ((p.numeroCC ?? '').isNotEmpty)
        (rotulo: 'Cartão de Cidadão', valor: p.numeroCC!),
      if ((p.numeroUtente ?? '').isNotEmpty)
        (rotulo: 'Nº de utente', valor: p.numeroUtente!),
    ];

    final estadoConsent = consent == null
        ? 'Por assinar'
        : consent.revogadoEm != null
            ? 'Revogado em ${fmt.format(consent.revogadoEm!)}'
            : 'Assinado em ${fmt.format(consent.assinadoEm)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nome, style: fonteTitulo.copyWith(fontSize: 22)),
        actions: [
          IconButton(
            tooltip: 'Editar ficha',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/paciente/$id/ficha'),
          ),
          IconButton(
            tooltip: 'PDF / Imprimir',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed:
                ficha == null ? null : () => context.push('/paciente/$id/pdf'),
          ),
          PopupMenuButton<String>(
            tooltip: 'Mais opções',
            onSelected: (v) async {
              if (v == 'identificacao') {
                await abrirIdentificacao(context, paciente: p);
              }
              if (v == 'apagar') {
                final apagado = await apagarPacienteComConfirmacao(context, ref, p);
                if (apagado && context.mounted) context.pop();
              }
            },
            itemBuilder: (_) => const [
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
                  title: Text('Apagar paciente',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Cabecalho(p, podeFotografar: consent?.valido ?? false),
          if (ident.isNotEmpty) _CartaoSecao('Identificação', ident),

          // Consentimento
          AuraCard(
            child: ListTile(
              leading: Icon(
                consent?.valido ?? false
                    ? Icons.verified_outlined
                    : Icons.draw_outlined,
                color: consent?.valido ?? false
                    ? const Color(0xFF7BA37B)
                    : AuraCores.rosa,
              ),
              title: const Text('Consentimento de imagens'),
              subtitle: Text(estadoConsent),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/paciente/$id/consent'),
            ),
          ),
          const SizedBox(height: 12),

          // Fotografias (anexadas à ficha)
          AuraCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/paciente/$id/fotos'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera_outlined,
                            color: AuraCores.rosa),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            fotos.isEmpty
                                ? 'Fotografias'
                                : 'Fotografias (${fotos.length})',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    if (fotos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: fotos.length > 8 ? 8 : fotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImagemBlob(fotos[i].caminho,
                                largura: 72, altura: 72, cacheWidth: 200),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _CartaoAcao(
            icone: Icons.monitor_weight_outlined,
            titulo: 'Consultas de obesidade',
            subtitulo: obes.isEmpty
                ? 'Peso, altura, IMC e notas por consulta'
                : '${obes.length} consulta(s) · último peso ${fmtNum(obes.last.peso)} kg · IMC ${fmtNum(obes.last.imc)}',
            aoTocar: () => context.push('/paciente/$id/obesidade'),
          ),
          _CartaoAcao(
            icone: Icons.edit_document,
            titulo: 'Consentimentos informados',
            subtitulo: consTrat.isEmpty
                ? 'Um por tratamento, com assinatura'
                : '${consTrat.length} assinado(s)',
            aoTocar: () => context.push('/paciente/$id/consentimentos'),
          ),
          _CartaoAcao(
            icone: Icons.mark_email_read_outlined,
            titulo: 'Recomendações pós-tratamento',
            subtitulo: 'Enviar por WhatsApp, e-mail ou PDF',
            aoTocar: () => context.push('/paciente/$id/recomendacoes'),
          ),
          if (ficha == null)
            AuraCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Esta ficha ainda não foi preenchida.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AuraCores.rosa),
                      onPressed: () => context.push('/paciente/$id/ficha'),
                      child: const Text('Preencher ficha'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final s in secoes)
              if (linhasPreenchidas(s, dados).isNotEmpty)
                _CartaoSecao(s.titulo, linhasPreenchidas(s, dados)),
            if (trat.isNotEmpty)
              _CartaoSecao('Tratamentos propostos', [
                for (final t in trat)
                  (rotulo: t['data'] ?? '', valor: t['tratamento'] ?? ''),
              ]),
          ],
        ],
      ),
      bottomNavigationBar: ficha == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraCores.rosa,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.push('/paciente/$id/pdf'),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Converter em PDF / Imprimir'),
                ),
              ),
            ),
    );
  }
}

class _CartaoSecao extends StatelessWidget {
  const _CartaoSecao(this.titulo, this.linhas);
  final String titulo;
  final List<Linha> linhas;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AuraCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: fonteTitulo.copyWith(fontSize: 18)),
                const Divider(height: 20),
                for (final l in linhas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(l.rotulo,
                              style: const TextStyle(
                                  color: AuraCores.textoSuave,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(flex: 3, child: Text(l.valor)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}


/// Foto do paciente (tipo passe). Toca para tirar, escolher ou remover.
class _Cabecalho extends ConsumerWidget {
  const _Cabecalho(this.p, {required this.podeFotografar});
  final Paciente p;
  final bool podeFotografar;

  Future<void> _escolher(BuildContext context, WidgetRef ref) async {
    if (!podeFotografar) {
      final ir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Foto do paciente'),
          content: const Text(
              'Para guardar a foto do paciente é preciso o consentimento de imagens assinado.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Agora não')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ir para o consentimento')),
          ],
        ),
      );
      if (ir == true && context.mounted) {
        context.push('/paciente/${p.id}/consent');
      }
      return;
    }

    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar fotografia'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, 'galeria'),
            ),
            if (p.fotoPerfil != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remover foto'),
                onTap: () => Navigator.pop(ctx, 'remover'),
              ),
          ],
        ),
      ),
    );
    if (acao == null) return;

    final repo = ref.read(repoProvider);
    if (acao == 'remover') {
      await repo.apagarBlob(p.fotoPerfil!);
      await repo.guardarPaciente(p.comFotoPerfil(null));
      return;
    }

    final x = await ImagePicker().pickImage(
      source: acao == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    // chave nova de cada vez, para a imagem atualizar logo
    final chave = 'perfil_${p.id}_${DateTime.now().millisecondsSinceEpoch}';
    await repo.guardarBlob(chave, bytes);
    if (p.fotoPerfil != null) await repo.apagarBlob(p.fotoPerfil!);
    await repo.guardarPaciente(p.comFotoPerfil(chave));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        child: Center(
          child: GestureDetector(
            onTap: () => _escolher(context, ref),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarPaciente(p, raio: 52),
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: AuraCores.rosa,
                    child:
                        Icon(Icons.photo_camera, size: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}


class _CartaoAcao extends StatelessWidget {
  const _CartaoAcao({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.aoTocar,
  });
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AuraCard(
          child: ListTile(
            leading: Icon(icone, color: AuraCores.rosa),
            title: Text(titulo),
            subtitle: Text(subtitulo),
            trailing: const Icon(Icons.chevron_right),
            onTap: aoTocar,
          ),
        ),
      );
}
