import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/repositorio.dart';

final repoProvider = Provider<Repositorio>(
  (ref) => throw UnimplementedError('repoProvider não inicializado'),
);

final pesquisaProvider = StateProvider<String>((ref) => '');

final pacientesProvider = StreamProvider<List<Paciente>>((ref) =>
    ref.watch(repoProvider).pacientes(ref.watch(pesquisaProvider)));

final pacienteProvider = StreamProvider.family<Paciente?, String>(
    (ref, id) => ref.watch(repoProvider).paciente(id));

final fichaProvider = StreamProvider.family<Ficha?, String>(
    (ref, id) => ref.watch(repoProvider).ficha(id));

final fichasPreenchidasProvider = StreamProvider<Set<String>>(
    (ref) => ref.watch(repoProvider).fichasPreenchidas());

final consentimentoProvider = StreamProvider.family<Consentimento?, String>(
    (ref, id) => ref.watch(repoProvider).consentimento(id));

extension ConsentimentoX on Consentimento {
  /// Só permite fotografar com consentimento de registo clínico e não revogado.
  bool get valido => revogadoEm == null && registoClinico;
}

final fotosProvider = StreamProvider.family<List<Foto>, String>(
    (ref, id) => ref.watch(repoProvider).fotos(id));

final ultimaCopiaProvider = StreamProvider<DateTime?>(
    (ref) => ref.watch(repoProvider).ultimaCopia());

final consultasObesidadeProvider =
    StreamProvider.family<List<ConsultaObesidade>, String>(
        (ref, id) => ref.watch(repoProvider).consultasObesidade(id));

/// tipo: 'consentimento' ou 'recomendacao'
final modelosProvider = StreamProvider.family<List<Modelo>, String>(
    (ref, tipo) => ref.watch(repoProvider).modelos(tipo));

final consentimentosTratProvider =
    StreamProvider.family<List<ConsentimentoTratamento>, String>(
        (ref, id) => ref.watch(repoProvider).consentimentosTrat(id));

/// Chave da imagem da assinatura da médica (ou null se ainda não existe).
final assinaturaMedicaProvider = StreamProvider<String?>(
    (ref) => ref.watch(repoProvider).assinaturaMedica());

/// Modo claro/escuro (guardado no aparelho).
final temaModoProvider = StateProvider<ThemeMode>((ref) =>
    ref.read(repoProvider).temaGuardado == 'escuro'
        ? ThemeMode.dark
        : ThemeMode.light);
