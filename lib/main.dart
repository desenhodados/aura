import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/key_store.dart';
import 'core/providers.dart';
import 'core/tema.dart';
import 'data/repositorio.dart';
import 'features/consent/consent_page.dart';
import 'features/consentimentos/assinar_consent_trat_page.dart';
import 'features/consentimentos/assinatura_medica_page.dart';
import 'features/consentimentos/consent_trat_pdf_page.dart';
import 'features/consentimentos/consentimentos_trat_page.dart';
import 'features/modelos/modelos_page.dart';
import 'features/obesidade/obesidade_page.dart';
import 'features/recomendacoes/recomendacoes_page.dart';

import 'features/copia/copia_page.dart';
import 'features/ficha/ficha_form_page.dart';
import 'features/ficha/ficha_pdf_page.dart';
import 'features/fotos/comparador_page.dart';
import 'features/fotos/fotos_page.dart';
import 'features/home/home_page.dart';
import 'features/pacientes/paciente_page.dart';
import 'features/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await Repositorio.abrir(await KeyStore.obterChave());
  runApp(ProviderScope(
    overrides: [repoProvider.overrideWithValue(repo)],
    child: const AuraApp(),
  ));
}

CustomTransitionPage<void> _fade(Widget child) => CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/copia', builder: (_, __) => const CopiaPage()),
    GoRoute(
      path: '/paciente/:id/obesidade',
      builder: (_, s) => ObesidadePage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/consentimentos',
      builder: (_, s) => ConsentimentosTratPage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/consentimentos/assinar/:modeloId',
      builder: (_, s) => AssinarConsentTratPage(
        pacienteId: s.pathParameters['id']!,
        modeloId: s.pathParameters['modeloId']!,
      ),
    ),
    GoRoute(
      path: '/consentimento-trat/:id/pdf',
      builder: (_, s) => ConsentTratPdfPage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/recomendacoes',
      builder: (_, s) =>
          RecomendacoesPage(pacienteId: s.pathParameters['id']!),
    ),
    GoRoute(
        path: '/assinatura-medica',
        builder: (_, __) => const AssinaturaMedicaPage()),
    GoRoute(path: '/modelos', builder: (_, __) => const ModelosPage()),
    GoRoute(
      path: '/modelos/editar/:id',
      builder: (_, s) => EditarModeloPage(modeloId: s.pathParameters['id']),
    ),
    GoRoute(
      path: '/modelos/novo/:tipo',
      builder: (_, s) => EditarModeloPage(tipo: s.pathParameters['tipo']),
    ),
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/', pageBuilder: (_, __) => _fade(const HomePage())),
    GoRoute(
      path: '/paciente/:id',
      builder: (_, s) => PacientePage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/ficha',
      builder: (_, s) => FichaFormPage(
        pacienteId: s.pathParameters['id']!,
        novo: s.uri.queryParameters['novo'] == '1',
      ),
    ),
    GoRoute(
      path: '/paciente/:id/pdf',
      builder: (_, s) => FichaPdfPage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/consent',
      builder: (_, s) => ConsentPage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/fotos',
      builder: (_, s) => FotosPage(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/paciente/:id/comparar',
      builder: (_, s) => ComparadorPage(id: s.pathParameters['id']!),
    ),
  ],
);

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Aura',
        debugShowCheckedModeBanner: false,
        theme: temaAura(),
        locale: const Locale('pt', 'PT'),
        supportedLocales: const [Locale('pt', 'PT')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
      );
}
