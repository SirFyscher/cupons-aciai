class ParsedCouponData {
  final String accessKey; // 44 dígitos
  final String cnpj;      // 14 dígitos
  final double? value;    // Valor total da compra se disponível no QR
  final DateTime? date;   // Data de emissão se disponível
  final String rawQrCode;

  ParsedCouponData({
    required this.accessKey,
    required this.cnpj,
    this.value,
    this.date,
    required this.rawQrCode,
  });

  String get formattedCnpj {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
  }

  String get formattedAccessKey {
    if (accessKey.length != 44) return accessKey;
    final buffer = StringBuffer();
    for (int i = 0; i < accessKey.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(accessKey[i]);
    }
    return buffer.toString();
  }
}

class CouponParser {
  /// Extrai a chave de 44 dígitos de qualquer texto/URL de cupom fiscal brasileiro (NFC-e / SAT)
  static ParsedCouponData? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final trimmed = rawText.trim();

    // 1. Procura uma sequência de 44 dígitos numéricos contínuos
    final keyRegex = RegExp(r'\b\d{44}\b');
    final match = keyRegex.firstMatch(trimmed);

    String? foundKey;
    if (match != null) {
      foundKey = match.group(0);
    } else {
      // Caso a chave esteja separada por barras, pipes ou em query param
      // Ex: .../qrcode?p=3526101234567800019065...|2|1|1|...
      final pipeParts = trimmed.split('|');
      for (final part in pipeParts) {
        final digitsOnly = part.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length == 44) {
          foundKey = digitsOnly;
          break;
        } else if (digitsOnly.length > 44) {
          final subMatch = keyRegex.firstMatch(digitsOnly);
          if (subMatch != null) {
            foundKey = subMatch.group(0);
            break;
          }
        }
      }
    }

    if (foundKey == null || foundKey.length != 44) {
      return null;
    }

    // Na chave de 44 dígitos:
    // Posições 0..1: Código UF (ex: 35)
    // Posições 2..5: AAMM (Ano/Mês da emissão)
    // Posições 6..19: CNPJ da empresa emitente (14 dígitos)
    final cnpj = foundKey.substring(6, 20);

    // Tenta extrair o valor da compra
    double? extractedValue;

    // Se for padrão SAT ou NFC-e delimitado por pipe: chave|datahora|valor|...
    if (trimmed.contains('|')) {
      final parts = trimmed.split('|');
      for (final p in parts) {
        final sanitized = p.replaceAll(',', '.');
        final val = double.tryParse(sanitized);
        if (val != null && val > 0 && val < 500000 && !p.contains(foundKey)) {
          // Candidato a valor se tiver casas decimais ou fizer sentido
          if (p.contains('.') || p.contains(',')) {
            extractedValue = val;
            break;
          }
        }
      }
    }

    // Se for URL com query params (ex: vTot=125.50 ou valor=...)
    if (extractedValue == null && trimmed.contains('?')) {
      try {
        final uri = Uri.parse(trimmed);
        final vTot = uri.queryParameters['vTot'] ?? uri.queryParameters['valor'];
        if (vTot != null) {
          extractedValue = double.tryParse(vTot.replaceAll(',', '.'));
        }
      } catch (_) {}
    }

    return ParsedCouponData(
      accessKey: foundKey,
      cnpj: cnpj,
      value: extractedValue,
      rawQrCode: trimmed,
    );
  }
}
