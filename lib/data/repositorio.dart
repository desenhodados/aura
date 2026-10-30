import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models.dart';
import 'modelos_padrao.dart';

/// Armazenamento local ENCRIPTADO (AES) para registos, fotos e assinaturas.
/// Funciona em Android, iOS e web, sem geração de código.
class Repositorio {
  Repositorio._({
    required Box<String> pacientes,
    required Box<String> fichas,
    required Box<String> consentimentos,
    required Box<String> fotos,
    required LazyBox<Uint8List> blobs,
    required Box<String> meta,
    required Box<String> consultasOb,
    required Box<String> modelos,
    required Box<String> consTrat,
  })  : _pacientes = pacientes,
        _fichas = fichas,
        _consentimentos = consentimentos,
        _fotos = fotos,
        _blobs = blobs,
        _meta = meta,
        _consultasOb = consultasOb,
        _modelos = modelos,
        _consTrat = consTrat;

  final Box<String> _pacientes;
  final Box<String> _fichas;
  final Box<String> _consentimentos;
  final Box<String> _fotos;
  final LazyBox<Uint8List> _blobs;
  final Box<String> _meta;
  final Box<String> _consultasOb;
  final Box<String> _modelos;
  final Box<String> _consTrat;
  final Map<String, Uint8List> _cache = {};

  static Future<Repositorio> abrir(List<int> chave) async {
    await Hive.initFlutter();
    final cifra = HiveAesCipher(chave);
    Future<Box<String>> caixa(String nome) =>
        Hive.openBox<String>(nome, encryptionCipher: cifra);

    final r = Repositorio._(
      pacientes: await caixa('pacientes'),
      fichas: await caixa('fichas'),
      consentimentos: await caixa('consentimentos'),
      fotos: await caixa('fotos'),
      blobs: await Hive.openLazyBox<Uint8List>('blobs', encryptionCipher: cifra),
      meta: await caixa('meta'),
      consultasOb: await caixa('consultas_ob'),
      modelos: await caixa('modelos'),
      consTrat: await caixa('cons_trat'),
    );
    await r._semearModelos();
    return r;
  }

  /// Na primeira vez, cria os modelos de consentimento e de recomendações.
  Future<void> _semearModelos({bool forcar = false}) async {
    if (!forcar && _meta.get('modelosSemeados') == '1') return;
    for (final m in modelosPadrao) {
      if (!_modelos.containsKey(m.id)) {
        await _modelos.put(m.id, jsonEncode(m.toJson()));
      }
    }
    await _meta.put('modelosSemeados', '1');
  }

  static Map<String, dynamic> _m(String s) =>
      Map<String, dynamic>.from(jsonDecode(s) as Map);

  /// Emite o valor atual e volta a emitir sempre que a "caixa" muda.
  Stream<T> _observar<T>(Box<String> box, T Function() ler) async* {
    yield ler();
    await for (final _ in box.watch()) {
      yield ler();
    }
  }

  // ---------- pacientes ----------
  Stream<List<Paciente>> pacientes(String termo) =>
      _observar<List<Paciente>>(_pacientes, () {
        final t = termo.trim().toLowerCase();
        final lista = _pacientes.values
            .map((s) => Paciente.fromJson(_m(s)))
            .where((p) =>
                t.isEmpty ||
                p.nome.toLowerCase().contains(t) ||
                (p.telemovel ?? '').contains(t) ||
                (p.numeroUtente ?? '').contains(t) ||
                (p.numeroCC ?? '').toLowerCase().contains(t))
            .toList()
          ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        return lista;
      });

  Stream<Paciente?> paciente(String id) => _observar<Paciente?>(_pacientes, () {
        final s = _pacientes.get(id);
        return s == null ? null : Paciente.fromJson(_m(s));
      });

  Future<Paciente?> lerPaciente(String id) async {
    final s = _pacientes.get(id);
    return s == null ? null : Paciente.fromJson(_m(s));
  }

  Future<void> guardarPaciente(Paciente p) =>
      _pacientes.put(p.id, jsonEncode(p.toJson()));

  /// Apaga o paciente e TUDO o que lhe pertence: ficha, consentimentos,
  /// assinaturas, fotografias, consultas de obesidade.
  Future<void> apagarPaciente(String id) async {
    await apagarFotosDe(id);
    final cons = _consentimentos.values
        .map((s) => Consentimento.fromJson(_m(s)))
        .where((c) => c.pacienteId == id)
        .toList();
    for (final c in cons) {
      await apagarBlob(c.caminhoAssinatura);
      await _consentimentos.delete(c.id);
    }
    final ct = _consTrat.values
        .map((s) => ConsentimentoTratamento.fromJson(_m(s)))
        .where((c) => c.pacienteId == id)
        .toList();
    for (final c in ct) {
      await apagarConsentimentoTrat(c);
    }
    final ob = _consultasOb.values
        .map((s) => ConsultaObesidade.fromJson(_m(s)))
        .where((c) => c.pacienteId == id)
        .toList();
    for (final c in ob) {
      await _consultasOb.delete(c.id);
    }
    await _fichas.delete(id);
    await _pacientes.delete(id);
  }

  // ---------- fichas ----------
  Stream<Ficha?> ficha(String pacienteId) =>
      _observar<Ficha?>(_fichas, () => _lerFicha(pacienteId));

  Future<Ficha?> lerFicha(String pacienteId) async => _lerFicha(pacienteId);

  Ficha? _lerFicha(String pacienteId) {
    final s = _fichas.get(pacienteId);
    return s == null ? null : Ficha.fromJson(_m(s));
  }

  Future<void> guardarFicha(Ficha f) =>
      _fichas.put(f.pacienteId, jsonEncode(f.toJson()));

  Stream<Set<String>> fichasPreenchidas() => _observar<Set<String>>(
      _fichas, () => _fichas.keys.map((k) => k.toString()).toSet());

  // ---------- consentimento de imagens ----------
  Stream<Consentimento?> consentimento(String pacienteId) =>
      _observar<Consentimento?>(_consentimentos, () {
        Consentimento? melhor;
        for (final s in _consentimentos.values) {
          final c = Consentimento.fromJson(_m(s));
          if (c.pacienteId != pacienteId) continue;
          if (melhor == null || c.assinadoEm.isAfter(melhor.assinadoEm)) {
            melhor = c;
          }
        }
        return melhor;
      });

  Future<void> guardarConsentimento(Consentimento c) =>
      _consentimentos.put(c.id, jsonEncode(c.toJson()));

  // ---------- fotografias ----------
  Stream<List<Foto>> fotos(String pacienteId) =>
      _observar<List<Foto>>(_fotos, () {
        final lista = _fotos.values
            .map((s) => Foto.fromJson(_m(s)))
            .where((f) => f.pacienteId == pacienteId)
            .toList()
          ..sort((a, b) => a.tiradaEm.compareTo(b.tiradaEm));
        return lista;
      });

  Future<void> guardarFoto(Foto f) => _fotos.put(f.id, jsonEncode(f.toJson()));

  Future<void> apagarFoto(Foto f) async {
    await apagarBlob(f.caminho);
    await _fotos.delete(f.id);
  }

  Future<void> apagarFotosDe(String pacienteId) async {
    final lista = _fotos.values
        .map((s) => Foto.fromJson(_m(s)))
        .where((f) => f.pacienteId == pacienteId)
        .toList();
    for (final f in lista) {
      await apagarFoto(f);
    }
    // a foto de perfil também é uma imagem do paciente
    final s = _pacientes.get(pacienteId);
    if (s != null) {
      final p = Paciente.fromJson(_m(s));
      if (p.fotoPerfil != null) {
        await apagarBlob(p.fotoPerfil!);
        await guardarPaciente(p.comFotoPerfil(null));
      }
    }
  }

  // ---------- consultas de obesidade ----------
  Stream<List<ConsultaObesidade>> consultasObesidade(String pacienteId) =>
      _observar<List<ConsultaObesidade>>(_consultasOb, () {
        final l = _consultasOb.values
            .map((s) => ConsultaObesidade.fromJson(_m(s)))
            .where((c) => c.pacienteId == pacienteId)
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));
        return l;
      });

  Future<void> guardarConsultaObesidade(ConsultaObesidade c) =>
      _consultasOb.put(c.id, jsonEncode(c.toJson()));

  Future<void> apagarConsultaObesidade(String id) => _consultasOb.delete(id);

  // ---------- modelos de documentos ----------
  Stream<List<Modelo>> modelos(String tipo) => _observar<List<Modelo>>(_modelos, () {
        final l = _modelos.values
            .map((s) => Modelo.fromJson(_m(s)))
            .where((m) => m.tipo == tipo)
            .toList()
          ..sort((a, b) =>
              a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
        return l;
      });

  Future<Modelo?> lerModelo(String id) async {
    final s = _modelos.get(id);
    return s == null ? null : Modelo.fromJson(_m(s));
  }

  Future<void> guardarModelo(Modelo m) =>
      _modelos.put(m.id, jsonEncode(m.toJson()));

  Future<void> apagarModelo(String id) => _modelos.delete(id);

  /// Repõe os modelos originais que tenham sido apagados (não mexe nos editados).
  Future<void> reporModelosPadrao() => _semearModelos(forcar: true);

  // ---------- consentimentos informados (tratamentos) ----------
  Stream<List<ConsentimentoTratamento>> consentimentosTrat(String pacienteId) =>
      _observar<List<ConsentimentoTratamento>>(_consTrat, () {
        final l = _consTrat.values
            .map((s) => ConsentimentoTratamento.fromJson(_m(s)))
            .where((c) => c.pacienteId == pacienteId)
            .toList()
          ..sort((a, b) => b.assinadoEm.compareTo(a.assinadoEm));
        return l;
      });

  Future<ConsentimentoTratamento?> lerConsentimentoTrat(String id) async {
    final s = _consTrat.get(id);
    return s == null ? null : ConsentimentoTratamento.fromJson(_m(s));
  }

  Future<void> guardarConsentimentoTrat(ConsentimentoTratamento c) =>
      _consTrat.put(c.id, jsonEncode(c.toJson()));

  Future<void> apagarConsentimentoTrat(ConsentimentoTratamento c) async {
    await apagarBlob(c.caminhoAssinatura);
    if (c.caminhoAssinaturaMedica != null) {
      await apagarBlob(c.caminhoAssinaturaMedica!);
    }
    await _consTrat.delete(c.id);
  }

  // ---------- assinatura da médica (guardada uma vez) ----------
  Stream<String?> assinaturaMedica() =>
      _observar<String?>(_meta, () => _meta.get('assinaturaMedica'));

  String? get chaveAssinaturaMedica => _meta.get('assinaturaMedica');

  Future<void> guardarAssinaturaMedica(Uint8List png) async {
    final antiga = _meta.get('assinaturaMedica');
    final chave = 'assinatura_medica_${DateTime.now().millisecondsSinceEpoch}';
    await guardarBlob(chave, png);
    await _meta.put('assinaturaMedica', chave);
    if (antiga != null) await apagarBlob(antiga);
  }

  Future<void> removerAssinaturaMedica() async {
    final antiga = _meta.get('assinaturaMedica');
    if (antiga != null) await apagarBlob(antiga);
    await _meta.delete('assinaturaMedica');
  }

  // ---------- cópia de segurança ----------
  Stream<DateTime?> ultimaCopia() => _observar<DateTime?>(_meta, () {
        final s = _meta.get('ultimaCopia');
        return s == null ? null : DateTime.parse(s);
      });

  Future<void> registarCopia() =>
      _meta.put('ultimaCopia', DateTime.now().toIso8601String());

  /// Tudo o que está guardado (registos + fotos + assinaturas) num só objeto.
  Future<Map<String, dynamic>> exportar() async {
    final blobs = <String, String>{};
    for (final k in _blobs.keys) {
      final b = await _blobs.get(k);
      if (b != null) blobs[k.toString()] = base64Encode(b);
    }
    return {
      'formato': 2,
      'criadoEm': DateTime.now().toIso8601String(),
      'pacientes': _pacientes.values.map(_m).toList(),
      'fichas': _fichas.values.map(_m).toList(),
      'consentimentos': _consentimentos.values.map(_m).toList(),
      'fotos': _fotos.values.map(_m).toList(),
      'consultasObesidade': _consultasOb.values.map(_m).toList(),
      'modelos': _modelos.values.map(_m).toList(),
      'consentimentosTrat': _consTrat.values.map(_m).toList(),
      'assinaturaMedica': _meta.get('assinaturaMedica'),
      'blobs': blobs,
    };
  }

  /// [substituir] = apaga tudo primeiro; senão junta (ids iguais são atualizados).
  Future<void> importar(Map<String, dynamic> d,
      {required bool substituir}) async {
    if (substituir) {
      await _pacientes.clear();
      await _fichas.clear();
      await _consentimentos.clear();
      await _fotos.clear();
      await _consultasOb.clear();
      await _modelos.clear();
      await _consTrat.clear();
      await _blobs.clear();
      await _meta.delete('assinaturaMedica');
      _cache.clear();
    }
    List<Map<String, dynamic>> lista(String k) => ((d[k] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    for (final m in lista('pacientes')) {
      await _pacientes.put(m['id'] as String, jsonEncode(m));
    }
    for (final m in lista('fichas')) {
      await _fichas.put(m['pacienteId'] as String, jsonEncode(m));
    }
    for (final m in lista('consentimentos')) {
      await _consentimentos.put(m['id'] as String, jsonEncode(m));
    }
    for (final m in lista('fotos')) {
      await _fotos.put(m['id'] as String, jsonEncode(m));
    }
    for (final m in lista('consultasObesidade')) {
      await _consultasOb.put(m['id'] as String, jsonEncode(m));
    }
    for (final m in lista('modelos')) {
      await _modelos.put(m['id'] as String, jsonEncode(m));
    }
    for (final m in lista('consentimentosTrat')) {
      await _consTrat.put(m['id'] as String, jsonEncode(m));
    }
    final blobs = Map<String, dynamic>.from((d['blobs'] as Map?) ?? const {});
    for (final e in blobs.entries) {
      await _blobs.put(e.key, base64Decode(e.value as String));
    }
    final ass = d['assinaturaMedica'] as String?;
    if (ass != null && blobs.containsKey(ass)) {
      await _meta.put('assinaturaMedica', ass);
    }
    _cache.clear();
    // cópias antigas não têm modelos: repõe os originais
    if (_modelos.isEmpty) await _semearModelos(forcar: true);
  }

  // ---------- ficheiros (fotos, assinaturas) ----------
  Future<void> guardarBlob(String chave, Uint8List bytes) async {
    await _blobs.put(chave, bytes);
    _cache[chave] = bytes;
  }

  Future<Uint8List?> lerBlob(String chave) async {
    final c = _cache[chave];
    if (c != null) return c;
    final b = await _blobs.get(chave);
    if (b != null) {
      if (_cache.length > 40) _cache.remove(_cache.keys.first);
      _cache[chave] = b;
    }
    return b;
  }

  Future<void> apagarBlob(String chave) async {
    _cache.remove(chave);
    await _blobs.delete(chave);
  }
}
