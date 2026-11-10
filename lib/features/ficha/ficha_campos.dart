import 'package:flutter/material.dart';
import '../../core/tema.dart';
import 'ficha_modelo.dart';

/// Constrói o campo de formulário de um [Campo] da ficha (texto, sim/não,
/// escolha ou multi-escolha). Partilhado pelo formulário por passos e pelo
/// editor de uma só secção.
Widget construirCampo(
  BuildContext context,
  Campo c,
  Map<String, dynamic> dados,
  void Function(VoidCallback) setState,
  VoidCallback alterou,
) {
  switch (c.tipo) {
    case TipoCampo.texto:
    case TipoCampo.textoLongo:
    case TipoCampo.numero:
      final longo = c.tipo == TipoCampo.textoLongo;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: ValueKey(c.chave),
          initialValue: dados[c.chave]?.toString() ?? '',
          keyboardType: c.tipo == TipoCampo.numero
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          minLines: longo ? 2 : 1,
          maxLines: longo ? 5 : 1,
          decoration: InputDecoration(
            labelText: c.rotulo,
            suffixText: c.sufixo,
            filled: true,
            fillColor: context.superficie,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) {
            dados[c.chave] = v;
            alterou();
          },
        ),
      );

    case TipoCampo.simNao:
      final atual = dados[c.chave];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(child: Text(c.rotulo)),
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'Sim', label: Text('Sim')),
                ButtonSegment(value: 'Não', label: Text('Não')),
              ],
              selected: atual is String ? {atual} : <String>{},
              onSelectionChanged: (s) {
                setState(() {
                  if (s.isEmpty) {
                    dados.remove(c.chave);
                  } else {
                    dados[c.chave] = s.first;
                  }
                });
                alterou();
              },
            ),
          ],
        ),
      );

    case TipoCampo.escolha:
      final longa = c.opcoes.any((o) => o.length > 28);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!longa || c.rotulo != 'Fototipo')
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(c.rotulo,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            if (longa)
              ...c.opcoes.map((o) {
                final sel = dados[c.chave] == o;
                return AuraCard(
                  color: sel ? context.destaque : context.superficie,
                  child: ListTile(
                    dense: true,
                    title: Text(o),
                    trailing: sel
                        ? const Icon(Icons.check_circle,
                            color: AuraCores.rosa)
                        : null,
                    onTap: () {
                      setState(() {
                        if (sel) {
                          dados.remove(c.chave);
                        } else {
                          dados[c.chave] = o;
                        }
                      });
                      alterou();
                    },
                  ),
                );
              })
            else
              Wrap(
                spacing: 8,
                children: c.opcoes
                    .map((o) => ChoiceChip(
                          label: Text(o),
                          selected: dados[c.chave] == o,
                          onSelected: (on) {
                            setState(() {
                              if (on) {
                                dados[c.chave] = o;
                              } else {
                                dados.remove(c.chave);
                              }
                            });
                            alterou();
                          },
                        ))
                    .toList(),
              ),
          ],
        ),
      );

    case TipoCampo.multi:
      final atual = List<String>.from((dados[c.chave] as List?) ?? const []);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(c.rotulo,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Wrap(
              spacing: 8,
              children: c.opcoes
                  .map((o) => FilterChip(
                        label: Text(o),
                        selected: atual.contains(o),
                        onSelected: (on) {
                          if (on) {
                            atual.add(o);
                          } else {
                            atual.remove(o);
                          }
                          setState(() {
                            if (atual.isEmpty) {
                              dados.remove(c.chave);
                            } else {
                              dados[c.chave] = atual;
                            }
                          });
                          alterou();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      );
  }
}
