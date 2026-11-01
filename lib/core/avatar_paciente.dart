import 'package:flutter/material.dart';
import '../data/models.dart';
import 'imagem_blob.dart';
import 'tema.dart';

/// Foto do paciente (tipo passe) ou, se não houver, as iniciais.
class AvatarPaciente extends StatelessWidget {
  const AvatarPaciente(this.p, {super.key, this.raio = 24});
  final Paciente p;
  final double raio;

  String get _iniciais {
    final partes = p.nome.trim().split(RegExp(r'\s+'));
    final a = partes.first.isEmpty ? '?' : partes.first[0];
    final b = partes.length > 1 ? partes.last[0] : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final foto = p.fotoPerfil;
    if (foto != null) {
      return ClipOval(
        child: ImagemBlob(
          foto,
          largura: raio * 2,
          altura: raio * 2,
          cacheWidth: (raio * 4).round(),
        ),
      );
    }
    return CircleAvatar(
      radius: raio,
      backgroundColor: AuraCores.rosaDourado.withOpacity(0.35),
      child: Text(
        _iniciais,
        style: TextStyle(
          color: AuraCores.texto,
          fontWeight: FontWeight.w600,
          fontSize: raio * 0.7,
        ),
      ),
    );
  }
}
