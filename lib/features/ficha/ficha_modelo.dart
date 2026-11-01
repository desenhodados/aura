import 'dart:convert';
import '../../data/models.dart';

/// A ficha é definida aqui UMA vez: o formulário, o ecrã de leitura e o PDF
/// são gerados a partir destas listas. Para mudar a ficha, edita só este ficheiro.
enum TipoCampo { texto, textoLongo, numero, simNao, escolha, multi }

class Campo {
  const Campo(this.chave, this.rotulo, this.tipo,
      {this.opcoes = const [], this.sufixo});
  final String chave;
  final String rotulo;
  final TipoCampo tipo;
  final List<String> opcoes;
  final String? sufixo;
}

class Secao {
  const Secao(this.titulo, this.campos);
  final String titulo;
  final List<Campo> campos;
}

const secoes = <Secao>[
  Secao('Antecedentes estéticos', [
    Campo('queixa', 'Queixa principal', TipoCampo.textoLongo),
    Campo('tratPrevios', 'Tratamentos prévios', TipoCampo.textoLongo),
    Campo('cosmeticos', 'Cosméticos habituais', TipoCampo.texto),
    Campo('filtroSolar', 'Uso de filtro solar', TipoCampo.simNao),
    Campo('descanso', 'Horas de descanso', TipoCampo.numero, sufixo: 'h'),
  ]),
  Secao('Classificação de Fitzpatrick', [
    Campo('fitzpatrick', 'Fototipo', TipoCampo.escolha, opcoes: [
      'Tipo I · Branca-pálida · Queima facilmente · Não se bronzeia',
      'Tipo II · Branca · Queima facilmente · Bronzeia-se com dificuldade',
      'Tipo III · Branca · Pode queimar inicialmente · Bronzeia-se facilmente',
      'Tipo IV · Castanha-clara/oliva · Dificilmente queima · Bronzeia-se facilmente',
      'Tipo V · Parda · Habitualmente não se queima · Bronzeia-se facilmente',
      'Tipo VI · Negra · Não se queima · Torna-se mais escura',
    ]),
  ]),
  Secao('Antecedentes pessoais', [
    Campo('patologias', 'Patologias', TipoCampo.textoLongo),
    Campo('coagulacao', 'Alterações de coagulação', TipoCampo.simNao),
    Campo('imune', 'Patologia imune', TipoCampo.simNao),
    Campo('herpes', 'Herpes labial', TipoCampo.simNao),
    Campo('cirurgias', 'Cirurgias anteriores', TipoCampo.texto),
    Campo('medicacao', 'Medicação habitual', TipoCampo.texto),
    Campo('alergias', 'Alergias', TipoCampo.texto),
    Campo('ciclo', 'Ciclo menstrual', TipoCampo.escolha,
        opcoes: ['Regular', 'Irregular']),
    Campo('tabaco', 'Tabaco', TipoCampo.simNao),
    Campo('exercicio', 'Exercício físico', TipoCampo.simNao),
    Campo('alcool', 'Álcool', TipoCampo.simNao),
    Campo('antFamiliares', 'Antecedentes familiares', TipoCampo.textoLongo),
    Campo('histEstetica', 'História estética', TipoCampo.textoLongo),
  ]),
  Secao('Pele e rosto', [
    Campo('tipoPele', 'Tipo de pele', TipoCampo.escolha,
        opcoes: ['Normal', 'Seca', 'Atópica', 'Mista', 'Seborreica']),
    Campo('alteracoes', 'Alterações', TipoCampo.multi, opcoes: [
      'Desidratada',
      'Sensível/Reativa',
      'Falta O2',
      'Hiperpigmentada',
      'Acne',
      'Cuperose',
    ]),
    Campo('formaRosto', 'Forma do rosto', TipoCampo.escolha,
        opcoes: ['Oval', 'Redonda', 'Quadrada', 'Pera']),
  ]),
  Secao('1/3 Superior', [
    Campo('sup_flacidez', 'Flacidez', TipoCampo.simNao),
    Campo('sup_fixas', 'Rugas fixas', TipoCampo.multi,
        opcoes: ['Frontal', 'Glabela']),
    Campo('sup_dinamicas', 'Rugas dinâmicas', TipoCampo.multi,
        opcoes: ['Frontal', 'Glabela']),
  ]),
  Secao('1/3 Médio', [
    Campo('med_flacidez', 'Flacidez', TipoCampo.simNao),
    Campo('med_fixas', 'Rugas fixas', TipoCampo.multi,
        opcoes: ['Pré-auricular', 'Orbicular', 'Base do nariz']),
    Campo('med_dinamicas', 'Rugas dinâmicas', TipoCampo.multi,
        opcoes: ['Pré-auricular', 'Orbicular', 'Base do nariz']),
  ]),
  Secao('1/3 Inferior', [
    Campo('inf_flacidez', 'Flacidez', TipoCampo.simNao),
    Campo('inf_arco', 'Perda do arco mandibular', TipoCampo.simNao),
    Campo('inf_labios', 'Lábios finos', TipoCampo.simNao),
    Campo('inf_assim', 'Assimétricos', TipoCampo.simNao),
    Campo('inf_fixas', 'Rugas fixas', TipoCampo.multi,
        opcoes: ['Perilabial', 'Nasogeniana', 'Mento']),
    Campo('inf_dinamicas', 'Rugas dinâmicas', TipoCampo.multi,
        opcoes: ['Perilabial', 'Nasogeniana', 'Mento']),
  ]),
  Secao('Pescoço', [
    Campo('pescoco', 'Alterações', TipoCampo.multi, opcoes: [
      'Flacidez',
      'Assimetrias',
      'Rugas',
      'Perda de volume',
    ]),
  ]),
  Secao('Observações', [
    Campo('lesoes', 'Lesões cutâneas', TipoCampo.textoLongo),
    Campo('cicatrizacao', 'Cicatrização', TipoCampo.textoLongo),
    Campo('inestetismos', 'Inestetismos / Assimetrias', TipoCampo.textoLongo),
    Campo('celulite', 'Celulite', TipoCampo.textoLongo),
    Campo('outras', 'Outras', TipoCampo.textoLongo),
  ]),
  Secao('Dados antropométricos', [
    Campo('peso', 'Peso', TipoCampo.numero, sufixo: 'kg'),
    Campo('altura', 'Altura', TipoCampo.numero, sufixo: 'cm'),
    Campo('perAbd', 'Perímetro abdominal', TipoCampo.numero, sufixo: 'cm'),
    Campo('perCoxa', 'Perímetro coxa', TipoCampo.numero, sufixo: 'cm'),
    Campo('outrasMedidas', 'Outras medidas', TipoCampo.texto),
  ]),
];

typedef Linha = ({String rotulo, String valor});

/// Só devolve os campos que foram preenchidos.
List<Linha> linhasPreenchidas(Secao s, Map<String, dynamic> d) {
  final out = <Linha>[];
  for (final c in s.campos) {
    final v = d[c.chave];
    final vazio = v == null ||
        (v is String && v.trim().isEmpty) ||
        (v is List && v.isEmpty);
    if (vazio) continue;
    var txt = v is List ? v.join(', ') : v.toString();
    if (c.sufixo != null) txt = '$txt ${c.sufixo}';
    out.add((rotulo: c.rotulo, valor: txt));
  }
  return out;
}

Map<String, dynamic> dadosDe(Ficha? f) {
  if (f == null) return {};
  try {
    return Map<String, dynamic>.from(jsonDecode(f.dadosJson) as Map);
  } catch (_) {
    return {};
  }
}

List<Map<String, String>> tratamentosDe(Ficha? f) {
  if (f == null) return [];
  try {
    return (jsonDecode(f.tratamentosPropostosJson) as List)
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  } catch (_) {
    return [];
  }
}

int? idadeDe(DateTime? n) {
  if (n == null) return null;
  final hoje = DateTime.now();
  var idade = hoje.year - n.year;
  if (hoje.month < n.month || (hoje.month == n.month && hoje.day < n.day)) {
    idade--;
  }
  return idade;
}
