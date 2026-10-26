import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';
import '../models/campaign_model.dart';
import '../core/utils/coupon_parser.dart';
import 'campaign_service.dart';

class ValidationResult {
  final bool isApproved;
  final String title;
  final String message;
  final CouponModel? coupon;
  final List<String> generatedLuckyNumbers;

  ValidationResult({
    required this.isApproved,
    required this.title,
    required this.message,
    this.coupon,
    this.generatedLuckyNumbers = const [],
  });
}

class ValidationService extends ChangeNotifier {
  final CampaignService campaignService;
  final List<CouponModel> _validatedCoupons = [];

  List<CouponModel> get validatedCoupons => List.unmodifiable(_validatedCoupons);

  ValidationService({required this.campaignService}) {
    // Cupons de exemplo cadastrados
    final active = campaignService.activeCampaign;
    final merchant = campaignService.merchants.first;

    _validatedCoupons.add(
      CouponModel(
        accessKey: '35261012345678000190650010000123451000123456',
        userId: 'user_01',
        campaignId: active.id,
        merchant: merchant,
        totalValue: 125.90,
        luckyNumbers: ['184920', '184921'],
        validatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
  }

  int get totalLuckyNumbersCount {
    return _validatedCoupons.fold(0, (sum, item) => sum + item.luckyNumbers.length);
  }

  double get totalRegisteredValue {
    return _validatedCoupons.fold(0.0, (sum, item) => sum + item.totalValue);
  }

  /// Processa e valida a nota fiscal
  Future<ValidationResult> validateAndRegister({
    required String rawInput,
    required String userId,
    double? manualValue,
  }) async {
    // 1. Parser da Chave de 44 dígitos e CNPJ
    final parsed = CouponParser.parse(rawInput);
    if (parsed == null) {
      return ValidationResult(
        isApproved: false,
        title: 'Código Não Reconhecido',
        message: 'Não foi possível identificar uma chave fiscal válida de 44 dígitos (NFC-e ou SAT). Verifique o QR Code ou digite a chave.',
      );
    }

    final key = parsed.accessKey;
    final cnpj = parsed.cnpj;
    final finalValue = manualValue ?? parsed.value;

    // 2. Validação de Unicidade (Antifraude)
    final isDuplicate = _validatedCoupons.any((c) => c.accessKey == key);
    if (isDuplicate) {
      return ValidationResult(
        isApproved: false,
        title: 'Cupom Já Cadastrado',
        message: 'Este cupom fiscal (chave final ...${key.substring(36)}) já foi validado anteriormente e não pode ser reutilizado.',
      );
    }

    // 3. Validação do CNPJ da Loja Participante
    final merchant = campaignService.findMerchantByCnpj(cnpj);
    if (merchant == null) {
      return ValidationResult(
        isApproved: false,
        title: 'Loja Não Participante',
        message: 'O CNPJ emissor desta nota (${parsed.formattedCnpj}) não consta na lista de empresas associadas participantes desta campanha da ACIAI.',
      );
    }

    // 4. Validação do Valor da Compra (deve ser >= R$ 50,00)
    final campaign = campaignService.activeCampaign;
    if (finalValue == null || finalValue < campaign.minValue) {
      final valFormatted = finalValue != null ? 'R\$ ${finalValue.toStringAsFixed(2)}' : 'não identificado';
      return ValidationResult(
        isApproved: false,
        title: 'Valor Mínimo Não Atingido',
        message: 'O valor da compra ($valFormatted) precisa ser de no mínimo R\$ ${campaign.minValue.toStringAsFixed(2)} para concorrer ao sorteio.',
      );
    }

    // 5. Geração dos Números da Sorte (1 a cada R$ 50,00)
    final int numbersCount = (finalValue / campaign.valuePerLuckyNumber).floor();
    final List<String> generatedNumbers = [];
    final random = Random();

    for (int i = 0; i < numbersCount; i++) {
      // Gera número de 6 dígitos formatado
      final number = (100000 + random.nextInt(900000)).toString();
      generatedNumbers.add(number);
    }

    // 6. Registro do Cupom Aprovado
    final newCoupon = CouponModel(
      accessKey: key,
      userId: userId,
      campaignId: campaign.id,
      merchant: merchant,
      totalValue: finalValue,
      luckyNumbers: generatedNumbers,
      validatedAt: DateTime.now(),
      status: 'APROVADO',
    );

    _validatedCoupons.insert(0, newCoupon);
    notifyListeners();

    return ValidationResult(
      isApproved: true,
      title: 'Participação Aprovada!',
      message: 'Parabéns! Sua compra no ${merchant.tradeName} gerou $numbersCount número(s) da sorte para a campanha "${campaign.title}".',
      coupon: newCoupon,
      generatedLuckyNumbers: generatedNumbers,
    );
  }
}
