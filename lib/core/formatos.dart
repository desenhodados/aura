/// Número com vírgula decimal (ex.: 82,4).
String fmtNum(double v, {int casas = 1}) =>
    v.toStringAsFixed(casas).replaceAll('.', ',');

/// Lê um número escrito com vírgula ou ponto. Devolve null se não for válido.
double? lerNum(String s) =>
    double.tryParse(s.trim().replaceAll(',', '.'));

/// "ana maria costa" -> "Ana"
String primeiroNome(String nome) {
  final p = nome.trim().split(RegExp(r'\s+'));
  return p.isEmpty || p.first.isEmpty ? '' : p.first;
}
