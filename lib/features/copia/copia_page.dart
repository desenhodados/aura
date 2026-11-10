import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/guardar_ficheiro.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';
import '../../data/copia_seguranca.dart';

/// Backup (guardar numa pasta à escolha) e Restore (repor a partir de uma cópia).
/// [modo]: 'backup', 'restore' ou nulo (mostra os dois).
class CopiaPage extends ConsumerStatefulWidget {
  const CopiaPage({super.key, this.modo});
  final String? modo;
  @override
  ConsumerState<CopiaPage> createState() => _CopiaPageState();
}

class _CopiaPageState extends ConsumerState<CopiaPage> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _ver = false;

  bool get _mostraBackup => widget.modo != 'restore';
  bool get _mostraRestore => widget.modo != 'backup';

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  void _aviso(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _ocupado(String msg) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(msg)),
            ],
          ),
        ),
      ),
    );
  }

  void _fecharOcupado() {
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  // ---------- backup ----------
  Future<void> _exportar(BuildContext botaoCtx, {required bool partilhar}) async {
    if (_pw1.text.length < 8) {
      _aviso('A palavra-passe deve ter pelo menos 8 caracteres.');
      return;
    }
    if (_pw1.text != _pw2.text) {
      _aviso('As palavras-passe não coincidem.');
      return;
    }
    final repo = ref.read(repoProvider);
    _ocupado('A preparar a cópia...');
    await Future<void>.delayed(const Duration(milliseconds: 200));

    Uint8List bytes;
    try {
      final dados = await repo.exportar();
      bytes = await CopiaSeguranca.cifrar(dados, _pw1.text);
    } catch (e) {
      _fecharOcupado();
      _aviso('Erro ao criar a cópia: $e');
      return;
    }
    _fecharOcupado();
    if (!mounted) return;

    final nome = 'Aura_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.aura';
    try {
      bool feito;
      if (partilhar) {
        final box = botaoCtx.findRenderObject() as RenderBox?;
        final zona =
            box == null ? null : box.localToGlobal(Offset.zero) & box.size;
        await entregarFicheiro(bytes, nome, zona);
        feito = true;
      } else {
        feito = await guardarNumaPasta(bytes, nome);
      }
      if (feito) {
        await repo.registarCopia();
        _pw1.clear();
        _pw2.clear();
        _aviso(partilhar
            ? 'Cópia criada. Confirma que o ficheiro ficou guardado.'
            : 'Backup guardado.');
      } else {
        _aviso('Backup cancelado.');
      }
    } catch (e) {
      _aviso('Não foi possível guardar o backup: $e');
    }
  }

  // ---------- restore ----------
  Future<String?> _pedirPalavraPasse() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Palavra-passe da cópia'),
        content: TextField(
          controller: c,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Palavra-passe'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Abrir')),
        ],
      ),
    );
  }

  Future<void> _importar() async {
    final r = await FilePicker.platform.pickFiles(
      dialogTitle: 'Escolhe o ficheiro de backup (.aura)',
      type: FileType.any,
      withData: true,
    );
    if (r == null || r.files.isEmpty) return;
    final bytes = r.files.first.bytes;
    if (bytes == null) {
      _aviso('Não foi possível ler o ficheiro.');
      return;
    }
    if (!mounted) return;
    final pw = await _pedirPalavraPasse();
    if (pw == null || pw.isEmpty || !mounted) return;

    _ocupado('A abrir a cópia...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    Map<String, dynamic> dados;
    try {
      dados = await CopiaSeguranca.decifrar(bytes, pw);
    } on FormatException catch (e) {
      _fecharOcupado();
      _aviso(e.message);
      return;
    } catch (e) {
      _fecharOcupado();
      _aviso('Erro ao abrir a cópia: $e');
      return;
    }
    _fecharOcupado();
    if (!mounted) return;

    final nPac = ((dados['pacientes'] as List?) ?? const []).length;
    final nFotos = ((dados['fotos'] as List?) ?? const []).length;
    final modo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar cópia'),
        content: Text(
            'A cópia tem $nPac paciente(s) e $nFotos fotografia(s).\n\n'
            '• Juntar: mantém o que já tens e acrescenta/atualiza a partir da cópia.\n'
            '• Substituir tudo: apaga o que está agora na app e repõe a cópia.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'juntar'),
              child: const Text('Juntar')),
          FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, 'substituir'),
              child: const Text('Substituir tudo')),
        ],
      ),
    );
    if (modo == null || !mounted) return;

    _ocupado('A restaurar...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      await ref
          .read(repoProvider)
          .importar(dados, substituir: modo == 'substituir');
      _fecharOcupado();
      _aviso('Cópia restaurada.');
    } catch (e) {
      _fecharOcupado();
      _aviso('Erro ao restaurar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultima = ref.watch(ultimaCopiaProvider).valueOrNull;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final titulo = widget.modo == 'backup'
        ? 'Backup'
        : widget.modo == 'restore'
            ? 'Restore'
            : 'Cópia de segurança';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo, style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            ultima == null
                ? 'Ainda não fizeste nenhuma cópia.'
                : 'Última cópia: ${fmt.format(ultima)}',
            style: const TextStyle(color: AuraCores.textoSuave),
          ),
          const SizedBox(height: 12),
          if (_mostraBackup)
            AuraCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Fazer backup',
                        style: fonteTitulo.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(
                      'Cria um ficheiro .aura com todas as fichas, consentimentos, assinaturas e fotografias, protegido por palavra-passe. '
                      '${kIsWeb ? 'No browser, o ficheiro vai para a pasta de transferências (ou o navegador pergunta onde guardar).' : 'Escolhes a pasta onde o queres guardar.'}',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pw1,
                      obscureText: !_ver,
                      decoration: InputDecoration(
                        labelText: 'Palavra-passe (mín. 8 caracteres)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _ver ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _ver = !_ver),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pw2,
                      obscureText: !_ver,
                      decoration: const InputDecoration(
                        labelText: 'Repetir palavra-passe',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Se perderes esta palavra-passe, a cópia não pode ser aberta por ninguém.',
                      style:
                          TextStyle(color: AuraCores.textoSuave, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (btnCtx) => FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AuraCores.rosa,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _exportar(btnCtx, partilhar: false),
                        icon: const Icon(Icons.folder_outlined),
                        label: Text(kIsWeb
                            ? 'Guardar backup'
                            : 'Escolher pasta e guardar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (btnCtx) => OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => _exportar(btnCtx, partilhar: true),
                        icon: const Icon(Icons.ios_share),
                        label: const Text('Partilhar (e-mail, iCloud, AirDrop...)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_mostraBackup && _mostraRestore) const SizedBox(height: 16),
          if (_mostraRestore)
            AuraCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Fazer restore',
                        style: fonteTitulo.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    const Text(
                        'Abre a pasta onde guardaste a cópia e escolhe o ficheiro .aura. Depois indicas a palavra-passe e podes juntar ao que já tens ou substituir tudo.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _importar,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Escolher a pasta e o ficheiro'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
