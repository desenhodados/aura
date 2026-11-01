import '../data/models.dart';

bool _bissexto(int a) => (a % 4 == 0 && a % 100 != 0) || a % 400 == 0;

/// Próximo aniversário (hoje conta como "0 dias"). 29/fev passa a 28/fev em anos não bissextos.
DateTime proximoAniversario(DateTime nascimento, DateTime hoje) {
  final h = DateTime(hoje.year, hoje.month, hoje.day);
  DateTime noAno(int ano) {
    final dia = (nascimento.month == 2 && nascimento.day == 29 && !_bissexto(ano))
        ? 28
        : nascimento.day;
    return DateTime(ano, nascimento.month, dia);
  }

  var d = noAno(h.year);
  if (d.isBefore(h)) d = noAno(h.year + 1);
  return d;
}

class Aniversario {
  const Aniversario(this.paciente, this.data, this.dias, this.idade);
  final Paciente paciente;
  final DateTime data;
  final int dias; // 0 = hoje
  final int idade; // idade que faz
}

/// Aniversários dentro de [dias] dias, do mais próximo para o mais distante.
List<Aniversario> proximosAniversarios(List<Paciente> pacientes, DateTime hoje,
    {int dias = 30}) {
  final h = DateTime(hoje.year, hoje.month, hoje.day);
  final out = <Aniversario>[];
  for (final p in pacientes) {
    final n = p.dataNascimento;
    if (n == null) continue;
    final d = proximoAniversario(n, h);
    final falta = d.difference(h).inDays;
    if (falta <= dias) out.add(Aniversario(p, d, falta, d.year - n.year));
  }
  out.sort((a, b) {
    final c = a.dias.compareTo(b.dias);
    return c != 0 ? c : a.paciente.nome.compareTo(b.paciente.nome);
  });
  return out;
}

String textoQuando(int dias) =>
    dias == 0 ? 'hoje' : (dias == 1 ? 'amanhã' : 'em $dias dias');
