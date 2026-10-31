import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'aura_simbolo.dart';
import 'tema.dart';
import 'versao.dart';

/// Menu lateral: Configurações, Feedback, Sobre nós e a versão da app.
class AuraDrawer extends StatelessWidget {
  const AuraDrawer({super.key});

  /// Fecha o drawer e navega para a rota indicada.
  /// Usa `context.go` em vez de `router.push` para SUBSTITUIR a rota atual
  /// e evitar empilhar a mesma página duas vezes (o que fazia parecer
  /// que a secção "Documentos" estava duplicada em Configurações).
  void _ir(BuildContext context, String rota) {
    Navigator.of(context).pop(); // fecha o menu
    context.go(rota);
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.escuro
                          ? AuraCores.fundoEscuro
                          : AuraCores.fundo,
                      context.escuro
                          ? AuraCores.fundoEscuroFim
                          : AuraCores.fundoFim,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const AuraSimbolo(tamanho: 92),
                    const SizedBox(height: 6),
                    Text('AURA',
                        style: fonteTitulo.copyWith(
                            fontSize: 26, letterSpacing: 8)),
                    const SizedBox(height: 2),
                    Text('medicina estética',
                        style: fonteTitulo.copyWith(
                          fontSize: 13,
                          letterSpacing: 2,
                          fontStyle: FontStyle.italic,
                          color: AuraCores.textoSuave,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_outlined,
                          color: AuraCores.rosa),
                      title: const Text('Configurações'),
                      onTap: () => _ir(context, '/configuracoes'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.rate_review_outlined,
                          color: AuraCores.rosa),
                      title: const Text('Feedback'),
                      onTap: () => _ir(context, '/feedback'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline,
                          color: AuraCores.rosa),
                      title: const Text('Sobre nós'),
                      onTap: () => _ir(context, '/sobre'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.verified_outlined,
                    color: AuraCores.textoSuave),
                title: const Text('Versão da App'),
                trailing: Text(versaoApp,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AuraCores.texto)),
              ),
            ],
          ),
        ),
      );
}
