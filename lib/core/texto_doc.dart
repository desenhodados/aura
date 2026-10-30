import 'package:flutter/material.dart';
import '../data/models.dart';
import 'formatos.dart';

/// Um bloco é um título se estiver todo em maiúsculas (ex.: "DECLARO").
bool ehTituloBloco(String b) {
  final t = b.trim();
  if (t.contains('\n') || t.length > 110 || t.endsWith('.')) return false;
  if (RegExp(r'^\d+\.\s').hasMatch(t)) return false;
  final letras = t.replaceAll(RegExp(r'[^A-Za-zÁÀÂÃÉÊÍÓÔÕÚÇáàâãéêíóôõúç]'), '');
  return letras.length >= 5 && t == t.toUpperCase();
}

/// Divide o texto em blocos (separados por linha em branco).
List<String> blocosDe(String texto) => texto
    .split(RegExp(r'\n\s*\n'))
    .map((b) => b.trim())
    .where((b) => b.isNotEmpty)
    .toList();

/// Substitui {nome}, {primeiro_nome} e {data} no texto de um modelo.
String substituirMarcadores(String texto, Paciente p, DateTime data) => texto
    .replaceAll('{nome}', p.nome)
    .replaceAll('{primeiro_nome}', primeiroNome(p.nome))
    .replaceAll(
        '{data}',
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}');

/// Mostra o texto de um documento (títulos a negrito).
class TextoDocumento extends StatelessWidget {
  const TextoDocumento(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) {
    final blocos = blocosDe(texto);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocos)
          Padding(
            padding: EdgeInsets.only(
                top: ehTituloBloco(b) ? 10 : 0, bottom: 8),
            child: Text(
              b,
              style: TextStyle(
                height: 1.4,
                fontWeight:
                    ehTituloBloco(b) ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
