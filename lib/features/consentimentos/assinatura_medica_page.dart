import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../core/imagem_blob.dart';
import '../../core/providers.dart';
import '../../core/tema.dart';

/// A assinatura da médica é guardada uma vez e usada em todos os consentimentos.
class AssinaturaMedicaPage extends ConsumerStatefulWidget {
  const AssinaturaMedicaPage({super.key});
  @override
  ConsumerState<AssinaturaMedicaPage> createState() => _AssinaturaMedicaPageState();
}

class _AssinaturaMedicaPageState extends ConsumerState<AssinaturaMedicaPage> {
  final _sig = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _desenhando = false;

  @override
  void initState() {
    super.initState();
    _sig.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sig.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final png = await _sig.toPngBytes();
    if (png == null) return;
    await ref.read(repoProvider).guardarAssinaturaMedica(png);
    _sig.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assinatura da médica guardada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final atual = ref.watch(assinaturaMedicaProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text('Assinatura da médica',
            style: fonteTitulo.copyWith(fontSize: 20)),
      ),
      body: ListView(
        physics: _desenhando ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'Esta assinatura é guardada uma vez e aparece automaticamente em todos os consentimentos informados que forem assinados a partir de agora.'),
          const SizedBox(height: 16),
          if (atual != null) ...[
            const Text('Assinatura atual',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AuraCores.rosaDourado),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ImagemBlob(atual, fit: BoxFit.contain),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref.read(repoProvider).removerAssinaturaMedica(),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover'),
              ),
            ),
            const Divider(height: 28),
          ],
          Row(
            children: [
              Expanded(
                child: Text(atual == null ? 'Assinar' : 'Substituir por nova assinatura',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: _sig.clear,
                icon: const Icon(Icons.refresh),
                label: const Text('Limpar'),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AuraCores.rosaDourado),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Listener(
              onPointerDown: (_) => setState(() => _desenhando = true),
              onPointerUp: (_) => setState(() => _desenhando = false),
              onPointerCancel: (_) => setState(() => _desenhando = false),
              child: Signature(
                controller: _sig,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AuraCores.rosa,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _sig.isNotEmpty ? _guardar : null,
            child: const Text('Guardar assinatura'),
          ),
        ],
      ),
    );
  }
}
