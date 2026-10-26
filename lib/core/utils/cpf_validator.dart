class CpfValidator {
  static String format(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.length > 11) return clean.substring(0, 11);
    
    if (clean.length <= 3) return clean;
    if (clean.length <= 6) {
      return '${clean.substring(0, 3)}.${clean.substring(3)}';
    }
    if (clean.length <= 9) {
      return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6)}';
    }
    return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6, 9)}-${clean.substring(9)}';
  }

  static bool isValid(String? cpf) {
    if (cpf == null) return false;
    final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cleanCpf.length != 11) return false;

    // Elimina CPFs conhecidos como inválidos (todos os dígitos iguais)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanCpf)) return false;

    // Cálculo do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    int firstRemainder = (sum * 10) % 11;
    if (firstRemainder == 10 || firstRemainder == 11) firstRemainder = 0;
    if (firstRemainder != int.parse(cleanCpf[9])) return false;

    // Cálculo do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    int secondRemainder = (sum * 10) % 11;
    if (secondRemainder == 10 || secondRemainder == 11) secondRemainder = 0;
    if (secondRemainder != int.parse(cleanCpf[10])) return false;

    return true;
  }
}
