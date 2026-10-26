import 'merchant_model.dart';

class CouponModel {
  final String accessKey; // 44 dígitos únicos
  final String userId;
  final String campaignId;
  final MerchantModel merchant;
  final double totalValue;
  final List<String> luckyNumbers; // Ex: ["048291", "048292"]
  final DateTime validatedAt;
  final String status; // "APROVADO", "RECUSADO"

  CouponModel({
    required this.accessKey,
    required this.userId,
    required this.campaignId,
    required this.merchant,
    required this.totalValue,
    required this.luckyNumbers,
    required this.validatedAt,
    this.status = 'APROVADO',
  });

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
