import 'package:flutter/material.dart';
import '../../core/aura_simbolo.dart';
import '../../core/tema.dart';
import '../../core/versao.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  Widget _topico(IconData icone, String titulo, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: AuraCores.rosa),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(texto, style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Sobre nós', style: fonteTitulo.copyWith(fontSize: 20)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Center(child: AuraSimbolo(tamanho: 120)),
            Center(
              child: Text('AURA',
                  style: fonteTitulo.copyWith(fontSize: 30, letterSpacing: 10)),
            ),
            Center(
              child: Text('medicina estética',
                  style: fonteTitulo.copyWith(
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
                      color: AuraCores.textoSuave)),
            ),
            const SizedBox(height: 24),
            const Text(
              'A Aura é uma aplicação de apoio ao dia a dia do consultório de '
              'medicina estética e de obesidade. Reúne num só lugar o registo '
              'clínico de cada paciente, os documentos que a paciente assina e '
              'o que é entregue no fim da consulta.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 22),
            Text('O que a Aura faz',
                style: fonteTitulo.copyWith(fontSize: 20)),
            const SizedBox(height: 12),
            _topico(Icons.assignment_outlined, 'Ficha de avaliação inicial',
                'Identificação (com cartão de cidadão e nº de utente), antecedentes, fototipo, pele e rosto, tratamentos propostos e medidas.'),
            _topico(Icons.monitor_weight_outlined, 'Consultas de obesidade',
                'Peso, altura e IMC calculado automaticamente em cada consulta, com a evolução e as tuas notas.'),
            _topico(Icons.edit_document, 'Consentimentos informados',
                'Um modelo para cada tratamento, assinado no ecrã pela paciente e pela médica, e o consentimento para recolha de imagens.'),
            _topico(Icons.photo_camera_outlined, 'Fotografias',
                'Foto do paciente e fotografias de antes e depois, com comparador lado a lado.'),
            _topico(Icons.mark_email_read_outlined, 'Recomendações pós-tratamento',
                'Texto pronto para cada tratamento, para enviar por WhatsApp, e-mail ou PDF.'),
            _topico(Icons.picture_as_pdf_outlined, 'PDF da ficha',
                'A ficha completa, com os consentimentos assinados, para imprimir ou partilhar.'),
            _topico(Icons.backup_outlined, 'Backup e restore',
                'Cópia de segurança protegida por palavra-passe, para guardares onde quiseres.'),
            const SizedBox(height: 10),
            Text('Privacidade', style: fonteTitulo.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'Os dados ficam guardados apenas no teu aparelho, encriptados. '
              'A Aura não tem contas nem envia informação dos pacientes para servidores.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 14),
            const Text(
              'A Aura é uma ferramenta de apoio ao registo. A responsabilidade '
              'clínica e o conteúdo dos documentos são do profissional de saúde.',
              style: TextStyle(color: AuraCores.textoSuave, height: 1.4),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('Versão $versaoApp',
                  style: const TextStyle(color: AuraCores.textoSuave)),
            ),
          ],
        ),
      );
}
