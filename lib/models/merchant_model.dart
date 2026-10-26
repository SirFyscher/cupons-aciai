class MerchantModel {
  final String cnpj; // Apenas dígitos (14)
  final String tradeName; // Nome Fantasia
  final String legalName; // Razão Social
  final String category;  // Ex: Supermercado, Loja de Roupas, Farmácia, Calçados
  final String address;
  final bool isActive;

  MerchantModel({
    required this.cnpj,
    required this.tradeName,
    required this.legalName,
    required this.category,
    required this.address,
    this.isActive = true,
  });

  String get formattedCnpj {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
  }
}
