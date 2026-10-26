import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/validation_service.dart';
import '../../widgets/lucky_number_badge.dart';

class MyCouponsScreen extends StatelessWidget {
  final ValidationService validationService;

  const MyCouponsScreen({super.key, required this.validationService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: validationService,
      builder: (context, _) {
        final coupons = validationService.validatedCoupons;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meus Números da Sorte'),
          ),
          body: coupons.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppTheme.greenBackgroundLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Nenhum cupom cadastrado ainda',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Faça compras a partir de R\$ 50,00 nas lojas associadas à ACIAI e escaneie o cupom para gerar seus números da sorte!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = coupons[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.merchant.tradeName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenBackgroundLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'R\$ ${item.totalValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CNPJ: ${item.merchant.formattedCnpj}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Validado em: ${item.validatedAt.day.toString().padLeft(2, '0')}/${item.validatedAt.month.toString().padLeft(2, '0')}/${item.validatedAt.year} às ${item.validatedAt.hour.toString().padLeft(2, '0')}:${item.validatedAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          const Divider(height: 24, color: AppTheme.cardBorder),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.luckyNumbers.length} Número(s) Gerado(s):',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const Icon(Icons.verified_outlined, size: 16, color: AppTheme.success),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: item.luckyNumbers.map((num) {
                              return LuckyNumberBadge(number: num);
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
