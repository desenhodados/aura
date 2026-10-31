import 'dart:math' as math;

DateTime? _d(dynamic v) => v == null ? null : DateTime.parse(v as String);

class Paciente {
  const Paciente({
    required this.id,
    required this.nome,
    this.dataNascimento,
    this.profissao,
    this.telemovel,
    this.email,
    this.numeroCC,
    this.numeroUtente,
    this.fotoPerfil,
    required this.criadoEm,
  });
  final String id;
  final String nome;
  final DateTime? dataNascimento;
  final String? profissao;
  final String? telemovel;
  final String? email;

  /// Número do cartão de cidadão.
  final String? numeroCC;

  /// Número de utente (SNS).
  final String? numeroUtente;

  /// Chave da foto de perfil (tipo passe) no armazenamento de ficheiros.
  final String? fotoPerfil;
  final DateTime criadoEm;

  Paciente comFotoPerfil(String? chave) => Paciente(
        id: id,
        nome: nome,
        dataNascimento: dataNascimento,
        profissao: profissao,
        telemovel: telemovel,
        email: email,
        numeroCC: numeroCC,
        numeroUtente: numeroUtente,
        fotoPerfil: chave,
        criadoEm: criadoEm,
      );

  /// Atualiza a identificação (mantém id, foto e data de criação).
  Paciente editar({
    required String nome,
    DateTime? dataNascimento,
    String? profissao,
    String? telemovel,
    String? email,
    String? numeroCC,
    String? numeroUtente,
  }) =>
      Paciente(
        id: id,
        nome: nome,
        dataNascimento: dataNascimento,
        profissao: profissao,
        telemovel: telemovel,
        email: email,
        numeroCC: numeroCC,
        numeroUtente: numeroUtente,
        fotoPerfil: fotoPerfil,
        criadoEm: criadoEm,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'profissao': profissao,
        'telemovel': telemovel,
        'email': email,
        'numeroCC': numeroCC,
        'numeroUtente': numeroUtente,
        'fotoPerfil': fotoPerfil,
        'criadoEm': criadoEm.toIso8601String(),
      };

  factory Paciente.fromJson(Map<String, dynamic> j) => Paciente(
        id: j['id'] as String,
        nome: j['nome'] as String,
        dataNascimento: _d(j['dataNascimento']),
        profissao: j['profissao'] as String?,
        telemovel: j['telemovel'] as String?,
        email: j['email'] as String?,
        numeroCC: j['numeroCC'] as String?,
        numeroUtente: j['numeroUtente'] as String?,
        fotoPerfil: j['fotoPerfil'] as String?,
        criadoEm: DateTime.parse(j['criadoEm'] as String),
      );
}

/// Respostas da ficha (JSON por secção) + tratamentos propostos.
class Ficha {
  const Ficha({
    required this.pacienteId,
    this.dadosJson = '{}',
    this.tratamentosPropostosJson = '[]',
    required this.atualizadaEm,
  });
  final String pacienteId;
  final String dadosJson;
  final String tratamentosPropostosJson;
  final DateTime atualizadaEm;

  Map<String, dynamic> toJson() => {
        'pacienteId': pacienteId,
        'dadosJson': dadosJson,
        'tratamentosPropostosJson': tratamentosPropostosJson,
        'atualizadaEm': atualizadaEm.toIso8601String(),
      };

  factory Ficha.fromJson(Map<String, dynamic> j) => Ficha(
        pacienteId: j['pacienteId'] as String,
        dadosJson: j['dadosJson'] as String? ?? '{}',
        tratamentosPropostosJson: j['tratamentosPropostosJson'] as String? ?? '[]',
        atualizadaEm: DateTime.parse(j['atualizadaEm'] as String),
      );
}

/// Consentimento de imagens (fotografias).
class Consentimento {
  const Consentimento({
    required this.id,
    required this.pacienteId,
    required this.versaoTexto,
    required this.registoClinico,
    required this.comparacaoResultados,
    required this.divulgacao,
    required this.caminhoAssinatura,
    this.hashDocumento,
    required this.assinadoEm,
    this.revogadoEm,
  });
  final String id;
  final String pacienteId;
  final String versaoTexto;
  final bool registoClinico;
  final bool comparacaoResultados;
  final bool divulgacao;
  final String caminhoAssinatura;
  final String? hashDocumento;
  final DateTime assinadoEm;
  final DateTime? revogadoEm;

  Consentimento revogar(DateTime quando) => Consentimento(
        id: id,
        pacienteId: pacienteId,
        versaoTexto: versaoTexto,
        registoClinico: registoClinico,
        comparacaoResultados: comparacaoResultados,
        divulgacao: divulgacao,
        caminhoAssinatura: caminhoAssinatura,
        hashDocumento: hashDocumento,
        assinadoEm: assinadoEm,
        revogadoEm: quando,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pacienteId': pacienteId,
        'versaoTexto': versaoTexto,
        'registoClinico': registoClinico,
        'comparacaoResultados': comparacaoResultados,
        'divulgacao': divulgacao,
        'caminhoAssinatura': caminhoAssinatura,
        'hashDocumento': hashDocumento,
        'assinadoEm': assinadoEm.toIso8601String(),
        'revogadoEm': revogadoEm?.toIso8601String(),
      };

  factory Consentimento.fromJson(Map<String, dynamic> j) => Consentimento(
        id: j['id'] as String,
        pacienteId: j['pacienteId'] as String,
        versaoTexto: j['versaoTexto'] as String,
        registoClinico: j['registoClinico'] as bool,
        comparacaoResultados: j['comparacaoResultados'] as bool,
        divulgacao: j['divulgacao'] as bool,
        caminhoAssinatura: j['caminhoAssinatura'] as String,
        hashDocumento: j['hashDocumento'] as String?,
        assinadoEm: DateTime.parse(j['assinadoEm'] as String),
        revogadoEm: _d(j['revogadoEm']),
      );
}

class Foto {
  const Foto({
    required this.id,
    required this.pacienteId,
    this.consultaId,
    required this.caminho,
    this.angulo,
    this.momento = 'antes',
    required this.tiradaEm,
  });
  final String id;
  final String pacienteId;
  final String? consultaId;
  final String caminho;
  final String? angulo;
  final String momento; // 'antes' | 'depois'
  final DateTime tiradaEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'pacienteId': pacienteId,
        'consultaId': consultaId,
        'caminho': caminho,
        'angulo': angulo,
        'momento': momento,
        'tiradaEm': tiradaEm.toIso8601String(),
      };

  factory Foto.fromJson(Map<String, dynamic> j) => Foto(
        id: j['id'] as String,
        pacienteId: j['pacienteId'] as String,
        consultaId: j['consultaId'] as String?,
        caminho: j['caminho'] as String,
        angulo: j['angulo'] as String?,
        momento: j['momento'] as String? ?? 'antes',
        tiradaEm: DateTime.parse(j['tiradaEm'] as String),
      );
}

// ---------------------------------------------------------------------------
// Consulta de obesidade
// ---------------------------------------------------------------------------

class ConsultaObesidade {
  const ConsultaObesidade({
    required this.id,
    required this.pacienteId,
    required this.data,
    required this.peso,
    required this.alturaCm,
    this.notas = '',
  });
  final String id;
  final String pacienteId;
  final DateTime data;

  /// kg
  final double peso;

  /// cm
  final double alturaCm;

  /// Notas pessoais da consulta (texto livre).
  final String notas;

  double get imc {
    final m = alturaCm / 100;
    return peso / math.pow(m, 2);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pacienteId': pacienteId,
        'data': data.toIso8601String(),
        'peso': peso,
        'alturaCm': alturaCm,
        'notas': notas,
      };

  factory ConsultaObesidade.fromJson(Map<String, dynamic> j) => ConsultaObesidade(
        id: j['id'] as String,
        pacienteId: j['pacienteId'] as String,
        data: DateTime.parse(j['data'] as String),
        peso: (j['peso'] as num).toDouble(),
        alturaCm: (j['alturaCm'] as num).toDouble(),
        notas: j['notas'] as String? ?? '',
      );
}

/// Classificação do IMC (OMS) para adultos.
String classificarImc(double imc) {
  if (imc < 18.5) return 'Baixo peso';
  if (imc < 25) return 'Peso normal';
  if (imc < 30) return 'Excesso de peso';
  if (imc < 35) return 'Obesidade classe I';
  if (imc < 40) return 'Obesidade classe II';
  return 'Obesidade classe III';
}

// ---------------------------------------------------------------------------
// Modelos de documentos (consentimentos informados e recomendações)
// ---------------------------------------------------------------------------

class Modelo {
  const Modelo({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.tituloDoc,
    required this.texto,
    required this.atualizadoEm,
  });
  final String id;

  /// 'consentimento' | 'recomendacao'
  final String tipo;

  /// Nome curto (na lista).
  final String titulo;

  /// Título que aparece no documento.
  final String tituloDoc;
  final String texto;
  final DateTime atualizadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'titulo': titulo,
        'tituloDoc': tituloDoc,
        'texto': texto,
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  factory Modelo.fromJson(Map<String, dynamic> j) => Modelo(
        id: j['id'] as String,
        tipo: j['tipo'] as String,
        titulo: j['titulo'] as String,
        tituloDoc: j['tituloDoc'] as String? ?? (j['titulo'] as String),
        texto: j['texto'] as String,
        atualizadoEm: DateTime.parse(j['atualizadoEm'] as String),
      );
}

/// Consentimento informado de um tratamento, assinado pelo paciente.
/// Guarda uma CÓPIA do texto e dos dados no momento da assinatura.
class ConsentimentoTratamento {
  const ConsentimentoTratamento({
    required this.id,
    required this.pacienteId,
    required this.modeloId,
    required this.titulo,
    required this.tituloDoc,
    required this.texto,
    required this.nomePaciente,
    required this.dataNascimentoTxt,
    required this.ccTxt,
    required this.assinadoEm,
    required this.caminhoAssinatura,
    this.caminhoAssinaturaMedica,
    this.hashDocumento,
  });
  final String id;
  final String pacienteId;
  final String modeloId;
  final String titulo;
  final String tituloDoc;
  final String texto;
  final String nomePaciente;
  final String dataNascimentoTxt;
  final String ccTxt;
  final DateTime assinadoEm;
  final String caminhoAssinatura;
  final String? caminhoAssinaturaMedica;
  final String? hashDocumento;

  Map<String, dynamic> toJson() => {
        'id': id,
        'pacienteId': pacienteId,
        'modeloId': modeloId,
        'titulo': titulo,
        'tituloDoc': tituloDoc,
        'texto': texto,
        'nomePaciente': nomePaciente,
        'dataNascimentoTxt': dataNascimentoTxt,
        'ccTxt': ccTxt,
        'assinadoEm': assinadoEm.toIso8601String(),
        'caminhoAssinatura': caminhoAssinatura,
        'caminhoAssinaturaMedica': caminhoAssinaturaMedica,
        'hashDocumento': hashDocumento,
      };

  factory ConsentimentoTratamento.fromJson(Map<String, dynamic> j) =>
      ConsentimentoTratamento(
        id: j['id'] as String,
        pacienteId: j['pacienteId'] as String,
        modeloId: j['modeloId'] as String,
        titulo: j['titulo'] as String,
        tituloDoc: j['tituloDoc'] as String,
        texto: j['texto'] as String,
        nomePaciente: j['nomePaciente'] as String,
        dataNascimentoTxt: j['dataNascimentoTxt'] as String? ?? '',
        ccTxt: j['ccTxt'] as String? ?? '',
        assinadoEm: DateTime.parse(j['assinadoEm'] as String),
        caminhoAssinatura: j['caminhoAssinatura'] as String,
        caminhoAssinaturaMedica: j['caminhoAssinaturaMedica'] as String?,
        hashDocumento: j['hashDocumento'] as String?,
      );
}
